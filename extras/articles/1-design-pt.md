# Projetando um PluginScript de Godot para Lua
2021-07-28 | `#Godot #Lua #GDNative #PluginScript #languageBindings` | [*English version*](1-design-en.md)

Esse é o primeiro artigo de uma série sobre como estou lidando com o
desenvolvimento de um *plugin* para usar a linguagem de programação [Lua](https://www.lua.org/portugues.html) no [motor de jogos Godot](https://godotengine.org/).

Lua é uma linguagem de *scripting* pequena e simples, mas poderosa e flexível.
Mesmo [não sendo ideal para todos os cenários](https://docs.godotengine.org/pt_BR/stable/about/faq.html#what-were-the-motivations-behind-creating-gdscript),
certamente é uma ótima ferramenta de *scripting*.
Combinando isso com o poder de [LuaJIT](https://luajit.org/), uma das
implementações de linguagens dinâmicas mais rápidas que se tem notícia, podemos
também [chamar funções externas de código C através da *Foreign Function Interface* (FFI)](https://luajit.org/ext_ffi.html)!

Com a natureza dinâmica do sistema de *scripting* em Godot,
todas as linguagens suportadas podem facilmente comunicar entre si, de
modo que podemos escolher utilizar a linguagem melhor
adaptada à tarefa a ser cumprida para cada *script*.
Utilizando [sinais](https://docs.godotengine.org/pt_BR/stable/getting_started/step_by_step/signals.html)
e os métodos [call](https://docs.godotengine.org/pt_BR/stable/classes/class_object.html#class-object-method-call),
[get](https://docs.godotengine.org/pt_BR/stable/classes/class_object.html#id1)
e [set](https://docs.godotengine.org/pt_BR/stable/classes/class_object.html#id4),
qualquer objeto pode se comunicar com qualquer outro, não importando
a linguagem na qual o código-fonte foi escrito.

Para fazer com que Lua seja reconhecida como uma linguagem de
*scripting* em Godot, vamos criar um *PluginScript*, que é um dos usos
do sistema [GDNative](https://docs.godotengine.org/pt_BR/stable/getting_started/step_by_step/scripting.html#gdnative-c),
a API em C para desenvolver *plugins* que estendem várias
funcionalidades do motor, incluindo o sistema de *scripting*.
Um dos benefícios desse método é que somente o *plugin* precisa ser
compilado, de modo que qualquer pessoa com uma versão padrão
precompilada de Godot possa utilizá-lo! =D


## Objetivos
- Adicionar suporte à linguagem Lua em Godot de um modo que o motor não
  precise ser compilado do zero
- Possibilitar que *scripts* Lua se comuniquem transparentemente com
  quaisquer outras linguagens suportadas, como GDScript, Visual Script e C#
- Ter uma interface descritiva simples para declarar *scripts*
- Suporte a Lua 5.2+ e LuaJIT
- Ter um processo de construção simples, onde qualquer um com o
  código-fonte em mãos e o sistema de construção + *toolchain*
  instalados possam compilar o projeto em um único passo


## Não objetivos
- Prover meios de chamar métodos nativamente nas classes padrão de Godot
  via *method bindings*
- Suportar *multithreading* em Lua


## *Script* exemplo
Este é um exemplo de como um *script* Lua se parecerá. Há comentários
explicando algumas decisões de *design*, que podem mudar ao longo do
desenvolvimento do projeto.

```lua
-- Definições de classes são tabelas, que devem ser retornadas no fim do script
local MinhaClasse = {}

-- Opcional: marcar classe como tool
MinhaClasse.is_tool = true

-- Opcional: declarar o nome da classe base, padrão 'Reference'
MinhaClasse.extends = 'Node'

-- Opcional: dê um nome à sua classe
MinhaClasse.class_name = 'MinhaClasse'

-- Declaração de sinais
MinhaClasse.um_sinal = signal()
MinhaClasse.um_sinal_com_argumentos = signal("arg1", "arg2")

-- Valores definidos na tabela são registrados como propriedades da classe
MinhaClasse.uma_propriedade = 42

-- A função `property` adiciona metadados às propriedades definidas,
-- como métodos setter e getter
MinhaClasse.uma_propriedade_com_detalhes = property {
  -- [1] ou ["default"] ou ["default_value"] = valor padrão da propriedade
  5,
  -- [2] ou ["type"] = tipo da variante, opcional, inferido do valor padrão
  -- Todos os nomes dos tipos de variantes serão definidos globalmente com
  -- o mesmo nome em GDScript, como bool, int, float, String, Array, etc...
  -- Note que Lua <= 5.2 não diferencia números inteiros de reais,
  -- então devemos especificar `int` sempre que apropriado
  -- ou usar `int(5)` no lugar do valor padrão
  type = int,
  -- ["set"] ou ["setter"] = função setter, opcional
  set = function(self, valor)
    self.uma_propriedade_com_detalhes = valor
    -- Indexar `self` com chaves não definidas no script buscará métodos
    -- e propriedades na classe base
    self:emit_signal("um_sinal_com_argumentos", "uma_propriedade_com_detalhes", valor)
  end,
  -- ["get"] ou ["getter"] = função getter, opcional
  get = function(self)
    return self.uma_propriedade_com_detalhes
  end,
  -- ["usage"] = flag de uso da propriedade, do enum godot_property_usage_flags
  -- opcional, usa GD.PROPERTY_USAGE_DEFAULT por padrão
  usage = GD.PROPERTY_USAGE_DEFAULT,
  -- ["hint"] = flag de dica da propriedade, do enum godot_property_hint
  -- opcional, usa GD.PROPERTY_HINT_NONE por padrão
  hint = GD.PROPERTY_HINT_RANGE,
  -- ["hint_string"] = texto da dica da propriedade, somente necessária
  -- para algumas dicas
  hint_string = '1,10',
  -- ["rset_mode"] = flag de RPC da propriedade, do enum godot_method_rpc_mode
  -- opcional, usa GD.RPC_MODE_DISABLED por padrão
  rset_mode = GD.RPC_MODE_MASTER,
}

-- Funções definidas na tabela são registrados como métodos
function MinhaClasse:_init()  -- `function t:f(...)` é uma abreviação de `function t.f(self, ...)`
  -- Singletons estão disponíveis globalmente
  local nome_os = OS:get_name()
  print("Instância de MinhaClasse inicializada! Rodando em um sistema " .. nome_os)
end

function MinhaClasse:uma_propriedade_dobrada()
  return self.uma_propriedade * 2
end

-- Ao final do script, a tabela com definição da classe deve ser retornada
return MinhaClasse
```


## Projeto da implementação
*PluginScripts* possuem três conceitos importantes: Descrição da
Linguagem, Manifestos de *Script* e Instâncias.

Vamos descobrir o que cada uma dessas camadas é e como elas se
comportarão, numa perspectiva alto nível:


### Descrição da Linguagem
A descrição da linguagem informa Godot como inicializar e finalizar o
*runtime* da linguagem, além de como carregar manifestos de scripts a
partir de arquivos com código-fonte.

Ao inicializar a linguagem, um novo [estado (lua_State)](https://www.lua.org/manual/5.2/pt/manual.html#lua_State) 
será criado e funcionalidade de Godot adicionada a ele.
A máquina virtual (VM) de Lua utilizará rotinas de gerenciamento de memória do motor, para
que o uso de memória seja rastreado pelo monitor de performance em
*builds* de *debug* dos jogos/aplicações.
Todos os *scripts* compartilharão desse mesmo estado.

Haverá uma tabela global chamada `GD` com funções específicas de Godot,
como [load](https://docs.godotengine.org/pt_BR/stable/classes/class_%40gdscript.html#class-gdscript-method-load),
[print](https://docs.godotengine.org/pt_BR/stable/classes/class_%40gdscript.html#class-gdscript-method-print),
[push_error](https://docs.godotengine.org/pt_BR/stable/classes/class_%40gdscript.html#class-gdscript-method-push-error),
[push_warning](https://docs.godotengine.org/pt_BR/stable/classes/class_%40gdscript.html#class-gdscript-method-push-warning)
e [yield](https://docs.godotengine.org/pt_BR/stable/classes/class_%40gdscript.html#class-gdscript-method-yield).
A função global de Lua `print` será trocada por `GD.print` e a 
[função de aviso em Lua 5.4](https://www.lua.org/manual/5.4/manual.html#lua_WarnFunction)
se comportará como uma chamada a `push_warning`.

Funções que recebem nomes de arquivos como argumento, por exemplo
[loadfile](https://www.lua.org/manual/5.2/pt/manual.html#pdf-loadfile)
e [io.open](https://www.lua.org/manual/5.2/pt/manual.html#pdf-io.open),
serão atualizadas para aceitar caminhos nos formatos [`res://*`](https://docs.godotengine.org/pt_BR/stable/tutorials/io/data_paths.html#resource-path)
e [`user://*`](https://docs.godotengine.org/pt_BR/stable/tutorials/io/data_paths.html#user-path-persistent-data).
Do mesmo modo, um [localizador de módulos](https://www.lua.org/manual/5.2/pt/manual.html#pdf-package.searchers)
será adicionado para [require](https://www.lua.org/manual/5.2/pt/manual.html#pdf-require)
carregue módulos relativos ao caminho `res://`.

Ao finalizar a linguagem, o estado da VM será destruído utilizando
[lua_close](https://www.lua.org/manual/5.2/pt/manual.html#lua_close).


### Manifestos de *Script*
Manifestos de *script* são estruturas que carregam metadados sobre as
classes declaradas nos *scripts*, por exemplo a definição de sinais,
propriedades e métodos, assim como se a classe roda em modo
[tool](https://docs.godotengine.org/pt_BR/stable/tutorials/misc/running_code_in_the_editor.html)
e o nome de sua classe base.

Em Lua, essa informação será guardada em tabelas indexadas pelo caminho
dos *scripts*.

Ao inicializar um *script*, seu código-fonte será carregado e executado.
*Scripts* devem retornar uma tabela, que definirá os metadados da classe.
Funções declaradas na tabela de manifesto são registradas como métodos
da classe e outras variáveis são declaradas como propriedades ou sinais.

Ao finalizar um *script*, a tabela do manifesto será destruída.


### Instâncias
Quando um *script* é adicionado a um objeto, Godot chamará nosso
*PluginScript* para inicializar os dados da instância e quando o objeto
for destruído ou tiver o *script* removido, devemos destruir esses
dados.

Em Lua, os dados de instâncias serão guardados em tabelas indexadas pelo
endereço de memória do objeto dono do script.

Quando instâncias são indexadas com uma chave não presente, métodos e
propriedades padrão serão buscados no manifesto do *script* e na classe
base, nessa ordem.
Essa tabela será passada nos métodos como primeiro argumento, como se
usado a notação de chamadas de método em Lua: `instancia:metodo(...)`.

Ao finalizar uma instância, a tabela será destruída.


## Conclusão
Com a funcionalidade projetada, mesmo que somente em alto nível, já
podemos começar a implementar nosso *plugin*!
Eu criei um repositório Git para ele, disponível no endereço
[https://github.com/gilzoide/godot-lua-pluginscript](https://github.com/gilzoide/godot-lua-pluginscript).

No [próximo artigo](2-infrastructure-pt.md) discutirei como construir a
infraestrutura necessária para nosso *PluginScript* funcionar, com
implementações vazias para os *callbacks* necessários e um sistema de
construção para compilar o projeto em um único passo.

Vejo vocês lá ;D
