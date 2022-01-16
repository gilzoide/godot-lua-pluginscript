# Implementando Godot Lua PluginScript: LuaJIT e FFI
2021-08-17 | `#Godot #LuaJIT #FFI #GDNative #PluginScript` | [*English Version*](3-luajit-callbacks-en.md)

Da última vez, [implementamos o esqueleto da nossa biblioteca GDNative + PluginScript](2-infrastructure-pt.md).
Hoje começaremos a integrar Lua no projeto e a implementar os *callbacks*.

Para podermos usar as definições de GDNative em Lua, temos duas opções:
implementar *wrappers* para tudo com a [API Lua/C](https://www.lua.org/manual/5.2/pt/manual.html#4)
ou usar declarações direto de C via [FFI](https://luajit.org/ext_ffi.html)
do [LuaJIT](https://luajit.org/) ou alguma outra implementação de FFI
como [cffi-lua](https://github.com/q66/cffi-lua).

Mesmo que seja fácil por si só criar *wrappers* pra Lua, tarefa
facilitada ainda por bibliotecas como [Sol](https://github.com/Rapptz/sol)
e geradores automáticos como [SWIG](http://swig.org/), usar a FFI é
ainda mais simples: basta copiar/colar definições dos arquivos de
cabeçalho e as definições estão disponíveis para serem usadas!
Além do mais, como LuaJIT é mais rápido que a implementação padrão de
Lua, o que é ótimo para aplicações de tempo real como jogos, usarei
LuaJIT + FFI para a primeira implementação do nosso *plugin*.


## Integrando LuaJIT
Primeira coisa: vamos adicionar LuaJIT à construção do projeto.
Convenientemente, [xmake](https://xmake.io) já sabe como fazer isso,
basta que a gente peça do jeito certo.
No arquivo `xmake.lua`, requerimos o pacote `luajit` e o adicionamos
como dependência do alvo (no inglês *target*):

```lua
-- xmake.lua
add_requires("luajit", {
    -- Força xmake a baixar e construir LuaJIT do zero,
    -- ao invés de procurar por uma versão instalada no sistema
    system = false,
    -- Liga o modo GC64 do LuaJIT, permitindo o uso de toda a memória
    -- disponível em sistemas de 64-bits, necessário também para
    -- plugarmos funções de gerenciamento de memória customizados na
    -- VM de Lua para esses sistemas
    config = {
        gc64 = true,
    },
})

target("lua_pluginscript")
    -- ...
    -- Adiciona "luajit" como dependência
    add_packages("luajit")
target_end()
```

Rode o comando `xmake`. Ele vai pedir uma confirmação para instalar o
pacote `luajit` em seu *cache*:

```
note: install or modify (m) these packages (pass -y to skip confirm)?
in xmake-repo:
  -> luajit 2.1.0-beta3 [gc64:y]
please input: y (y/n/m)
```

Confirme com a tecla `enter`, ou `y` e `enter` e LuaJIT será baixado
e contruído pra sua plataforma.

```
  => download http://luajit.org/download/LuaJIT-2.1.0-beta3.tar.gz .. ok
  => install luajit 2.1.0-beta3 .. ok
[100%]: build ok!
```

Ok, agora implementamos os dois primeiros *callbacks*: inicialização e
finalização da linguagem.
Pra fazer isso, incluímos os cabeçalhos de Lua em `src/language_gdnative.c`
e inicializamos/finalizamos o `lua_State`:

```c
// src/language_gdnative.c
#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"

// Função lua_Alloc: https://www.lua.org/manual/5.2/pt/manual.html#lua_Alloc
// Usa `hgdn_free` e `hgdn_realloc` pra que o gerenciamento de memória
// passe por Godot e o uso de memória seja acompanhado em builds de debug
void *lps_alloc(void *userdata, void *ptr, size_t osize, size_t nsize) {
    if (nsize == 0) {
        hgdn_free(ptr);
        return NULL;
    }
    else {
        return hgdn_realloc(ptr, nsize);
    }
}

// Chamada quando o ambiente de execução da linguagem for inicializado
godot_pluginscript_language_data *lps_language_init() {
    lua_State *L = lua_newstate(&lps_alloc, NULL);
    luaL_openlibs(L);  // Carrega bibliotecas padrão de Lua
    // TODO: rodar o script de inicialização usando FFI
    return L;
}

// Chamada quando o ambiente de execução da linguagem for finalizado
void lps_language_finish(godot_pluginscript_language_data *data) {
    lua_close((lua_State *) data);
}
```


## Embutindo o *script* de inicialização
Até aqui tudo bem. Agora, temos que chamar código Lua para inicializar a
FFI e implementar os outros *callbacks* lá.
Podemos escrever arquivos separados e carregá-los ou embutir o código
diretamente em C e compilá-lo junto com nossa biblioteca dinâmica.
Usar arquivos separados é bem melhor pra editar e ler, além de manter
o projeto organizado.
Por outro lado, embutir o código facilita muito seu carregamento e
execução, já que não precisamos preocupar com o caminho dos arquivos.
Já que podemos escolher, escolheremos ambos: podemos escrever um ou mais
arquivos, daí gerar o código C que define nosso *script* de
inicialização e compilá-lo junto com a biblioteca.

Pra testar isso, vamos construir um programa olá mundo em Lua:

```lua
-- src/ffi.lua
print "Olá mundo da Lua! \\o/"
```

O arquivo C precisa declarar uma constante global contendo o código, pra
que possamos rodá-lo na função `lps_language_init`, com uma *string*
literal, então aspas e contrabarras precisam ser escapadas.
A tradução do nosso olá mundo fica tipo assim:

```c
const char LUA_INIT_SCRIPT[] =
"-- src/ffi.lua\n"
"print \"Olá mundo da Lua! \\\\o/\"\n"
;
```

Pra criar o arquivo C de um ou mais arquivos, vamos juntar todos eles,
escapar aspas e contrabarras do conteúdo, adicionar aspas para cada
linha e por último adicionar a definição de `LUA_INIT_SCRIPT`.
Usarei o comando [cat](https://pt.wikipedia.org/wiki/Cat_%28Unix%29)
pra concatenar os arquivos e o comando [sed](https://pt.wikipedia.org/wiki/Sed)
pro resto.
Um jeito de fazer isso acontecer em `xmake` é criando uma [regra
customizada](https://xmake.io/#/manual/custom_rule)
e aplicá-la no nosso alvo:

```lua
-- xmake.lua
add_requires("luajit", {
    -- ...
})

rule("generate_init_script")
    -- A regra "generate_init_script" constrói um arquivo objeto
    set_kind("object")
    on_buildcmd_files(function(target, batchcmds, sourcebatch, opt)
        -- Caminho pro script Lua gerado: `build/init_script.lua`
        local full_script_path = vformat("$(buildir)/init_script.lua")
        -- Caminho pro arquivo C com o script Lua embutido:`build/init_script.c`
        local script_c_path = vformat("$(buildir)/init_script.c")
        -- É assim que adicionamos um arquivo objeto em um alvo em xmake
        local script_obj_path = target:objectfile(script_c_path)
        table.insert(target:objectfiles(), script_obj_path)

        batchcmds:show_progress(opt.progress, "${color.build.object}embed.lua (%s)", table.concat(sourcebatch.sourcefiles, ', '))
        -- Executa `cat src/*.lua > build/init_script.lua`
        batchcmds:execv("cat", sourcebatch.sourcefiles, { stdout = full_script_path })
        -- Executa `sed -e ↓SCRIPT_SED_ABAIXO↓ build/init_script.lua > build/init_script.c`
        batchcmds:execv("sed", { "-e", [[
        # Escapa contrabarras
        # (`s` substitui conteúdo, `g` significa trocar todas as ocorrências na linha)
        s/\\/\\\\/g
        # Escapa aspas
        s/"/\\"/g
        # Adiciona aspas iniciais
        # (`^` significa o começo da linha)
        s/^/"/
        # Adiciona fim de linha e aspas finais
        # (`$` significa o fim da linha)
        s/$/\\n"/
        # Adiciona as linhas de declaração em C:
        # (`i` insere uma linha antes de `1`, a primeira linha)
        1 i const char LUA_INIT_SCRIPT[] =
        # (`a` adiciona uma linha depois de `$`, a última linha)
        $ a ;
        ]], full_script_path }, { stdout = script_c_path })
        -- Finalmente, compila o arquivo C gerado
        batchcmds:compile(script_c_path, script_obj_path)
        -- Isto informa xmake pra somente reconstruir o arquivo
        -- objeto quando os arquivos Lua forem modificados
        batchcmds:add_depfiles(sourcebatch.sourcefiles)
        batchcmds:set_depmtime(os.mtime(script_obj_path))
    end)
rule_end()

target("lua_pluginscript")
    -- ...
    add_files("src/ffi.lua", { rule = "generate_init_script" })
target_end()
```

Agora tudo o que precisamos fazer é executar o código definido em
`const char LUA_INIT_SCRIPT[]`:

```c
extern const char LUA_INIT_SCRIPT[];

// Chamada quando o ambiente de execução da linguagem for inicializado
godot_pluginscript_language_data *lps_language_init() {
    lua_State *L = lua_newstate(&lps_alloc, NULL);
    luaL_openlibs(L);  // Load core Lua libraries
    if (luaL_dostring(L, LUA_INIT_SCRIPT) != LUA_OK) {
        const char *error_msg = lua_tostring(L, -1);
        HGDN_PRINT_ERROR("Erro ao executar script de inicialização: %s", error_msg);
    }
    return L;
}
```

Reconstrua o projeto com `xmake` e reabra Godot de um terminal e a
mensagem `Olá mundo da Lua! \o/` deve aparecer!

```
Godot Engine v3.3.2.stable.arch_linux - https://godotengine.org

Olá mundo da Lua! \o/
```


## Usando GDNative de Lua: FFI
Antes de começarmos a escrever os *callbacks* do nosso *PluginScript*,
precisamos de uma maneira de chamar funções de GDNative a partir do
código Lua.
É aqui que entra a FFI.
Bora modificar o arquivo `src/ffi.lua` com as definições:

```lua
-- src/ffi.lua
-- Arquivo completo em: https://github.com/gilzoide/godot-lua-pluginscript/blob/blog-3-luajit-callbacks/src/ffi.lua
local ffi = require 'ffi'

ffi.cdef[[
// Aqui dentro colamos as definições de C que precisarmos
// Não vou escrever tudo agora, porque é muuuita coisa
// Um link pro arquivo completo está listado acima

// Definições de tipos da API GDNative
typedef bool godot_bool;
typedef int godot_int;
typedef float godot_real;

typedef struct godot_object {
    uint8_t _dont_touch_that[0];
} godot_object;
typedef struct godot_string {
    uint8_t _dont_touch_that[sizeof(void *)];
} godot_string;
// ...

// Enums
typedef enum godot_error {
    GODOT_OK,
    GODOT_FAILED,
    // ...
} godot_error;
// ...

// API base
typedef struct godot_gdnative_api_version {
    unsigned int major;
    unsigned int minor;
} godot_gdnative_api_version;

typedef struct godot_gdnative_api_struct {
    unsigned int type;
    godot_gdnative_api_version version;
    const struct godot_gdnative_api_struct *next;
} godot_gdnative_api_struct;

typedef struct godot_gdnative_core_api_struct {
    unsigned int type;
    godot_gdnative_api_version version;
    const godot_gdnative_api_struct *next;
    unsigned int num_extensions;
    const godot_gdnative_api_struct **extensions;
    void (*godot_color_new_rgba)(godot_color *r_dest, const godot_real p_r, const godot_real p_g, const godot_real p_b, const godot_real p_a);
    void (*godot_color_new_rgb)(godot_color *r_dest, const godot_real p_r, const godot_real p_g, const godot_real p_b);
    godot_real (*godot_color_get_r)(const godot_color *p_self);
    // ...
} godot_gdnative_core_api_struct;
// ...

// Ponteiros globais pra API
const godot_gdnative_core_api_struct *hgdn_core_api;
]]

-- `hgdn_core_api` já estará inicializado nesse ponto, pela chamada a
-- `hgdn_gdnative_init` a partir da função `godot_gdnative_init`
local api = ffi.C.hgdn_core_api
```

Usando a variável `api`, um ponteiro para `godot_gdnative_core_api_struct`,
podemos chamar todas essas funções base de GDNative!
Vamos reescrever nosso olá mundo, dessa vez usando a `api`:

```lua
local ffi = require 'ffi'

ffi.cdef[[
// ...
]]

-- `hgdn_core_api` já estará inicializada nesse ponto, pela chamada a
-- `hgdn_gdnative_init` a partir da função `godot_gdnative_init`
local api = ffi.C.hgdn_core_api

local message = api.godot_string_chars_to_utf8("Olá mundo da Lua! \\o/")
api.godot_print(message)
-- Precisamos destruir todos os objetos que somos donos, assim como em C
api.godot_string_destroy(message)
-- Se não soubermos exatamente quando um objeto deve ser
-- destruído, devemos registrá-lo no Coletor de Lixo:
-- `ffi.gc(message, api.godot_string_destroy)`
-- Ref: https://luajit.org/ext_ffi_api.html#ffi_gc
```

Reconstrua o projeto e reabra o editor de Godot.
A mensagem deve aparecer novamente \o/


## FFI: Metatipos
Quando usamos a FFI, que é uma interface bem baixo nível, precisamos ter
muito cuidado com o gerenciamento de memória, SEGFAULTs e outros
problemas comuns encontrados em códigos C.
Todos os outros métodos para usar código C de Lua são susceptíveis a
esses mesmos problemas, então usar FFI ainda é uma boa ideia.

LuaJIT vai acompanhar e liberar a memória para dados criados em código
Lua, como `local some_array = ffi.new('int[1024]')`, mas pra executar
uma função destrutora customizada, como `api.godot_string_destroy`,
precisamos chamar a função explicitamente ou registrá-la no
Coletor de Lixo (no inglês *Garbage Collector*, abreviado para GC), para
que seja executada quando o objeto for coletado.

Fazer isso manualmente é muito chato e passível de erros, então vamos
trazer a API de GDNative mais perto do mundo de Lua declarando
[metatipos](https://luajit.org/ext_ffi_api.html#ffi_metatype).
Com metatipos, podemos definir uma [metatabela](https://www.lua.org/manual/5.2/pt/manual.html#2.4)
para dados definidos em código C, pra que eles tenham métodos, incluindo
construtor e destrutor, implementar operadores aritméticos e de
comparação, dentre outros.

Por enquanto, vou implementar somente o básico do tipo `godot_string`
pra que possamos imprimir mensagens nas funções de *callback*.
Essa implementação vai em um arquivo novo, `src/string.lua`, pra
mantermos o projeto organizado:

```lua
-- src/string.lua

-- Note que mesmo `api` sendo declarada como uma variável local em
-- `src/ffi.lua`, como os arquivos vão ser concatenados antes de rodar,
-- podemos acessá-la aqui

-- Métodos de String, tirados da API GDNative e ajustados para ficarem
-- mais idiomáticos pra código Lua, quando necessário
local string_methods = {
    -- Retorna o tamanho do texto
    length = api.godot_string_length,
    -- Retorna o conteúdo como uma string de Lua, codificada em UTF-8
    utf8 = function(self)
        -- `godot_string` guarda caracteres largos, então precisamos
        -- primeiro pegar a string de caracteres, pra daí criar uma
        -- string de Lua
        local char_string = api.godot_string_utf8(self)
        local pointer = api.godot_char_string_get_data(char_string)
        local length = api.godot_char_string_length(char_string)
        -- Ref: https://luajit.org/ext_ffi_api.html#ffi_string
        local lua_string = ffi.string(pointer, length)
        -- Assim como em C, precisamos destruir os dados que somos donos
        api.godot_char_string_destroy(char_string)
        return lua_string
    end,
}

-- Metatipo String, usado para instâncias de `godot_string`
-- Note que deixamos como uma variável global, pra que scripts
-- possam usar facilmente
String = ffi.metatype('godot_string', {
    -- Método construtor
    -- Chamar `String(value)` criará uma `godot_string` com
    -- o conteúdo de `valor` depois de passado por `tostring`
    __new = function(metatype, value)
        local self = ffi.new(metatype)
        -- Se `value` for outra `godot_string`, cria uma cópia
        if ffi.istype(metatype, value) then
            api.godot_string_new_copy(self, value)
        -- Caso geral
        else
            local str = tostring(value)
            api.godot_string_parse_utf8_with_len(self, str, #str)
        end
        return self
    end,
    -- Método destrutor
    __gc = api.godot_string_destroy,
    -- Usar a tabela de métodos como valor de `__index` faz com que os
    -- métodos estejam disponíveis a partir das instâncias
    -- Exemplo: `godot_string:length()`
    __index = string_methods,
    -- Operação de tamanho: `#godot_string` retorna o tamanho do texto
    __len = function(self)
        return string_methods.length(self)
    end,
    -- Chamar `tostring(godot_string)` vai invocar esse metamétodo
    __tostring = string_methods.utf8,
    -- Operação de concatenação: `godot_string .. godot_string` criará
    -- uma nova `godot_string` com o conteúdo de ambas concatenados
    __concat = function(a, b)
        -- Converter `a` e `b` para Strings possibilita expressões
        -- como `42 .. some_godot_string .. " some Lua string "`
        local str = api.godot_string_operator_plus(String(a), String(b))
        -- LuaJIT não consegue ter certeza se dados retornados de
        -- funções C devem ser acompanhadas ou não pelo Coletor de Lixo,
        -- já que APIs C podem requerer ou não que o objeto retornado
        -- seja destruído pelo usuário.
        -- Nos casos onde somos donos dos dados, como esse, pediremos
        -- pro GC acompanhar esse objeto.
        -- Na API GDNative, sempre que uma função retornar um objeto
        -- struct/union e não um ponteiro, somos donos dos dados.
        ffi.gc(str, api.godot_string_destroy)
        return str
    end,
})
```

Pra ter certeza que nossa implementação está funcionando, vou criar
também um arquivo `src/test.lua` e mover o código de teste de
`src/ffi.lua` para ele:

```lua
-- src/test.lua
local message = String("Olá mundo da Lua! \\o/")
api.godot_print(message)
```

Agora que temos mais arquivos Lua formando o *script* de inicialização,
precisamos especificar todos os arquivos em `xmake.lua`, na ordem certa:

```lua
-- xmake.lua
add_requires("luajit", {
    -- ...
})

rule("generate_init_script")
    -- ...
rule_end()

target("lua_pluginscript")
    -- ...
    add_files(
        -- A ordem é importante!
        -- Primeiro, declarações FFI
        "src/ffi.lua",
        -- Depois, implementação do metatipo String
        "src/string.lua",
        -- Finalmente, o código de teste
        "src/test.lua",
        { rule = "generate_init_script" }
    )
target_end()
```

Reconstruir o projeto e reabrir Godot deve mostrar a mensagem novamente.


## Executando *callbacks* de *PluginScript* em Lua
Último passo de hoje: vamos fazer os *callbacks* do nosso *plugin*
chamar código Lua.
O jeito mais fácil de fazer isso é declarar ponteiros de função globais,
um para cada *callback*, e preenchê-los com uma implementação feita em
Lua, usando FFI.

Em `src/language_gdnative.c`, vamos adicionar os ponteiros de função e
chamá-los:

```c
// src/language_gdnative.c

// ...

// Callbacks a serem implementados em Lua
void (*lps_language_add_global_constant_cb)(const godot_string *name, const godot_variant *value);
// Callbacks em LuaJIT não conseguem retornar structs por valor,
// então `manifest` será criado em C e passado por referência (ponteiro)
// Ref: https://luajit.org/ext_ffi_semantics.html#callback
void (*lps_script_init_cb)(godot_pluginscript_script_manifest *manifest, const godot_string *path, const godot_string *source, godot_error *error);
void (*lps_script_finish_cb)(godot_pluginscript_script_data *data);
godot_pluginscript_instance_data *(*lps_instance_init_cb)(godot_pluginscript_script_data *data, godot_object *owner);
void (*lps_instance_finish_cb)(godot_pluginscript_instance_data *data);
godot_bool (*lps_instance_set_prop_cb)(godot_pluginscript_instance_data *data, const godot_string *name, const godot_variant *value);
godot_bool (*lps_instance_get_prop_cb)(godot_pluginscript_instance_data *data, const godot_string *name, godot_variant *ret);
// Mesmo problema de `lps_script_init_cb`
void (*lps_instance_call_method_cb)(godot_pluginscript_instance_data *data, const godot_string_name *method, const godot_variant **args, int argcount, godot_variant *ret, godot_variant_call_error *error);
void (*lps_instance_notification_cb)(godot_pluginscript_instance_data *data, int notification);

// Chamada quando Godot registrar objetos globais, como nós Autoload
void lps_language_add_global_constant(godot_pluginscript_language_data *data, const godot_string *name, const godot_variant *value) {
    lps_language_add_global_constant_cb(name, value);
}

// Chamada quando um script Lua for carregado: const AlgumScript = preload("res://algum_script.lua")
godot_pluginscript_script_manifest lps_script_init(godot_pluginscript_language_data *data, const godot_string *path, const godot_string *source, godot_error *error) {
    godot_pluginscript_script_manifest manifest = {
        .data = NULL,
        .is_tool = false,
    };
    // Os objetos de Godot precisam ser inicializados, ou nosso
    // plugin dá SEGFAULT
    hgdn_core_api->godot_string_name_new_data(&manifest.name, "");
    hgdn_core_api->godot_string_name_new_data(&manifest.base, "");
    hgdn_core_api->godot_dictionary_new(&manifest.member_lines);
    hgdn_core_api->godot_array_new(&manifest.methods);
    hgdn_core_api->godot_array_new(&manifest.signals);
    hgdn_core_api->godot_array_new(&manifest.properties);

    // Marca que deu errado por padrão: a implementação é responsável
    // por marcar sucesso, quando de fato a chamada for bem sucedida
    godot_error cb_error = GODOT_ERR_SCRIPT_FAILED;
    lps_script_init_cb(&manifest, path, source, &cb_error);
    if (error) {
        *error = cb_error;
    }

    return manifest;
}

// Chamada quando um script Lua for finalizado
void lps_script_finish(godot_pluginscript_script_data *data) {
    lps_script_finish_cb(data);
}

// Chamada quando uma instância for criada: var instancia = AlgumScript.new()
godot_pluginscript_instance_data *lps_instance_init(godot_pluginscript_script_data *data, godot_object *owner) {
    return lps_instance_init_cb(data, owner);
}

// Chamada quando uma instância for finalizada
void lps_instance_finish(godot_pluginscript_instance_data *data) {
    lps_instance_finish_cb(data);
}

// Chamada ao escrever uma propriedade de instância: instancia.prop = valor
godot_bool lps_instance_set_prop(godot_pluginscript_instance_data *data, const godot_string *name, const godot_variant *value) {
    return lps_instance_set_prop_cb(data, name, value);
}

// Chamada ao ler uma propriedade de instância: var valor = instancia.prop
godot_bool lps_instance_get_prop(godot_pluginscript_instance_data *data, const godot_string *name, godot_variant *ret) {
    return lps_instance_get_prop_cb(data, name, ret);
}

// Chamada ao chamar um método em uma instância: instancia.metodo(args)
godot_variant lps_instance_call_method(godot_pluginscript_instance_data *data, const godot_string_name *method, const godot_variant **args, int argcount, godot_variant_call_error *error) {
    godot_variant var = hgdn_new_nil_variant();
    lps_instance_call_method_cb(data, method, args, argcount, &var, error);
    return var;
}

// Chamada quando uma notificação for enviada à instância
void lps_instance_notification(godot_pluginscript_instance_data *data, int notification) {
    lps_instance_notification_cb(data, notification);
}

// ...
```

Depois, adicionamos as definições desses *callbacks* em `src/ffi.lua`:

```lua
-- src/ffi.lua
local ffi = require 'ffi'

ffi.cdef[[
// ...

// Callbacks do PluginScript
void (*lps_language_add_global_constant_cb)(const godot_string *name, const godot_variant *value);
void (*lps_script_init_cb)(godot_pluginscript_script_manifest *manifest, const godot_string *path, const godot_string *source, godot_error *error);
void (*lps_script_finish_cb)(godot_pluginscript_script_data *data);
godot_pluginscript_instance_data *(*lps_instance_init_cb)(godot_pluginscript_script_data *data, godot_object *owner);
void (*lps_instance_finish_cb)(godot_pluginscript_instance_data *data);
godot_bool (*lps_instance_set_prop_cb)(godot_pluginscript_instance_data *data, const godot_string *name, const godot_variant *value);
godot_bool (*lps_instance_get_prop_cb)(godot_pluginscript_instance_data *data, const godot_string *name, godot_variant *ret);
void (*lps_instance_call_method_cb)(godot_pluginscript_instance_data *data, const godot_string_name *method, const godot_variant **args, int argcount, godot_variant *ret, godot_variant_call_error *error);
void (*lps_instance_notification_cb)(godot_pluginscript_instance_data *data, int notification);
]]

-- `hgdn_core_api` já estará inicializada nesse ponto, pela chamada a
-- `hgdn_gdnative_init` a partir da função `godot_gdnative_init`
local api = ffi.C.hgdn_core_api
```

Por fim, criamos um arquivo novo `src/pluginscript_callbacks.lua` para
implementá-los:

```lua
-- src/pluginscript_callbacks.lua

-- Função auxiliar que imprime erros
local function print_error(message)
    local info = debug.getinfo(2, 'nSl')
    api.godot_print_error(message, info.name, info.short_src, info.currentline)
end

-- Todos os callbacks rodarão em modo protegido, pra evitar que erros
-- em código Lua abortem o jogo/aplicação
-- Se ocorrer um erro, ele será impresso no painel de saída
local function wrap_callback(f)
    return function(...)
        local success, result = xpcall(f, print_error, ...)
        return result
    end
end

-- void (*lps_language_add_global_constant_cb)(const godot_string *name, const godot_variant *value);
ffi.C.lps_language_add_global_constant_cb = wrap_callback(function(name, value)
    api.godot_print(String('TODO: add_global_constant'))
end)

-- void (*lps_script_init_cb)(godot_pluginscript_script_manifest *manifest, const godot_string *path, const godot_string *source, godot_error *error);
ffi.C.lps_script_init_cb = wrap_callback(function(manifest, path, source, err)
    api.godot_print(String('TODO: script_init ' .. path))
end)

-- void (*lps_script_finish_cb)(godot_pluginscript_script_data *data);
ffi.C.lps_script_finish_cb = wrap_callback(function(data)
    api.godot_print(String('TODO: script_finish'))
end)

-- godot_pluginscript_instance_data *(*lps_instance_init_cb)(godot_pluginscript_script_data *data, godot_object *owner);
ffi.C.lps_instance_init_cb = wrap_callback(function(script_data, owner)
    api.godot_print(String('TODO: instance_init'))
    return nil
end)

-- void (*lps_instance_finish_cb)(godot_pluginscript_instance_data *data);
ffi.C.lps_instance_finish_cb = wrap_callback(function(data)
    api.godot_print(String('TODO: instance_finish'))
end)

-- godot_bool (*lps_instance_set_prop_cb)(godot_pluginscript_instance_data *data, const godot_string *name, const godot_variant *value);
ffi.C.lps_instance_set_prop_cb = wrap_callback(function(data, name, value)
    api.godot_print(String('TODO: instance_set_prop'))
    return false
end)

-- godot_bool (*lps_instance_get_prop_cb)(godot_pluginscript_instance_data *data, const godot_string *name, godot_variant *ret);
ffi.C.lps_instance_get_prop_cb = wrap_callback(function(data, name, ret)
    api.godot_print(String('TODO: instance_get_prop'))
    return false
end)

-- void (*lps_instance_call_method_cb)(godot_pluginscript_instance_data *data, const godot_string_name *method, const godot_variant **args, int argcount, godot_variant *ret, godot_variant_call_error *error);
ffi.C.lps_instance_call_method_cb = wrap_callback(function(data, name, args, argcount, ret, err)
    api.godot_print(String('TODO: instance_call_method'))
end)

-- void (*lps_instance_notification_cb)(godot_pluginscript_instance_data *data, int notification);
ffi.C.lps_instance_notification_cb = wrap_callback(function(data, what)
    api.godot_print(String('TODO: instance_notification'))
end)
```

Mais uma vez, adicionamos o arquivo novo no `xmake.lua` e reconstruímos:

```lua
-- xmake.lua

-- ...

target("lua_pluginscript")
    -- ...
    add_files(
        -- A ordem é importante!
        -- Primeiro, declarações FFI
        "src/ffi.lua",
        -- Depois, implementação do metatipo String
        "src/string.lua",
        -- Daí os callbacks
        "src/pluginscript_callbacks.lua",
        -- Finalmente, o código de teste
        "src/test.lua",
        { rule = "generate_init_script" }
    )
target_end()
```

Se abrirmos o arquivo `xmake.lua` em Godot, devemos ver a mensagem

`TODO: script_init res://addons/godot-lua-pluginscript/xmake.lua` no
painel de saída, já que o editor tentou inicializá-lo como um *script*:

![](3-script-init-xmake-lua.png)


## Conclusão
Hoje vimos como integrar LuaJIT em nosso projeto e como podemos
implementar *callbacks* em Lua via FFI.
A versão do projeto construída nesse artigo está disponível [aqui](https://github.com/gilzoide/godot-lua-pluginscript/tree/blog-3-luajit-callbacks).

No próximo artigo, vamos implementar inicialização e finalização dos
*scripts*.

Boa sorte pra todos nós, até a próxima!
