module lua
    use, intrinsic :: iso_c_binding
    use, intrinsic :: iso_fortran_env
    implicit none
    
    public :: lua_getglobal
    public :: lua_setglobal
    public :: lua_getfield
    public :: lua_setfield
    public :: lua_tointeger
    public :: lua_pushinteger
    public :: lua_geti
    public :: lua_seti


    integer(kind=c_int), parameter, public :: LUA_TNONE          = -1
    integer(kind=c_int), parameter, public :: LUA_TNIL           = 0
    integer(kind=c_int), parameter, public :: LUA_TBOOLEAN       = 1
    integer(kind=c_int), parameter, public :: LUA_TLIGHTUSERDATA = 2
    integer(kind=c_int), parameter, public :: LUA_TNUMBER        = 3
    integer(kind=c_int), parameter, public :: LUA_TSTRING        = 4
    integer(kind=c_int), parameter, public :: LUA_TTABLE         = 5
    integer(kind=c_int), parameter, public :: LUA_TFUNCTION      = 6
    integer(kind=c_int), parameter, public :: LUA_TUSERDATA      = 7
    integer(kind=c_int), parameter, public :: LUA_TTHREAD        = 8

    interface
        function lua_getglobal(l, name) bind(c, name='lua_getglobal')
            import c_ptr, c_int, c_char
            type(c_ptr),            intent(in), value :: l
            character(kind = c_char) name
            integer(kind=c_int) lua_getglobal
        end

        function lua_getfield_(l, idx, k) bind(c, name='lua_getfield')
            import c_char, c_int, c_ptr
            type(c_ptr),            intent(in), value :: l
            integer(kind=c_int),    intent(in), value :: idx
            character(kind=c_char), intent(in)        :: k
            integer(kind=c_int)                       :: lua_getfield_
        end

        function lua_geti(l, idx, i) bind(c,name='lua_geti')
            import c_char, c_int, c_ptr
            type(c_ptr) ,            intent(in), value :: l
            integer(kind=c_int) idx, i
            integer(kind=c_int) lua_geti
        end

        subroutine lua_setglobal(l, name) bind(c, name='lua_setglobal')
            import c_ptr, c_int, c_char
            type(c_ptr),            intent(in), value :: l
            character(kind = c_char) name
        end

        subroutine lua_setfield_(l, idx, k) bind(c, name='lua_setfield')
            import c_char, c_int, c_ptr
            type(c_ptr),            intent(in), value :: l
            integer(kind=c_int),    intent(in), value :: idx
            character(kind=c_char), intent(in)        :: k
        end

        subroutine lua_seti(l, idx, i) bind(c, name='lua_seti')
            import c_ptr, c_int
            type(c_ptr) ,            intent(in), value :: l
            integer(kind=c_int) idx, i
        end

        subroutine lua_pushinteger(l, n) bind(c, name='lua_pushinteger')
            import c_long_long, c_ptr
            type(c_ptr),            intent(in), value :: l
            integer(kind=c_long_long),    intent(in), value :: n
        end

        function lua_tointegerx(l, idx, isnum) bind(c, name='lua_tointegerx')
            import c_int, c_ptr, c_long_long
            type(c_ptr),            intent(in), value :: l
            integer(kind=c_int),            intent(in), value :: idx
            type(c_ptr),            intent(in), value :: isnum
            integer(kind=c_long_long) lua_tointegerx
        end
        
    end interface

    contains

    function lua_getfield(l, idx, k)
        type(c_ptr),            intent(in), value :: l
        integer idx
        character(len=*) k
        integer lua_getfield

        lua_getfield = lua_getfield_(l, idx, k // c_null_char)
    end

    subroutine lua_setfield(l, idx, k)
        type(c_ptr),            intent(in), value :: l
        integer idx
        character(len=*) k

        call lua_setfield_(l, idx, k // c_null_char)
    end

    function lua_tointeger(l, idx)
        type(c_ptr),            intent(in), value :: l
        integer(kind=c_int) idx

        integer(kind=c_long_long) lua_tointeger
        lua_tointeger = lua_tointegerx(l, idx, c_null_ptr)
    end

end