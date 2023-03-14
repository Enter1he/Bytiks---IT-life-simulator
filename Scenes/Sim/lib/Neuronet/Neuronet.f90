
module Neuronet
    use, intrinsic :: iso_c_binding
    use lua
    use dyn_Array
    implicit none

    public :: luaopen_Neuronet

    integer, public, parameter :: inps = 8
    integer, public, parameter :: outs = 3

    type Neuron
        real*8 :: bias = 0.0
    end type

    type Network
        class(Array), allocatable :: neur
        class(Array), allocatable :: syns
        contains 
            procedure :: AddNeuron
    end type

    contains
        subroutine AddNeuron(a)
            class(Network), intent(inout) :: a

            class(Neuron), allocatable :: n
            
            allocate(n)
            call a%neur%push_back(Elem(n))
        end

        subroutine RemoveNeuron(a, i)
            class(Network), intent(inout) :: a
            integer :: i

            class(*), allocatable :: n
            type(Elem) :: e

            e = a%neur%get_i(i)
            n = e%value
            call a%neur%del_exchg(i)
        end
        
        function luaopen_Neuronet(l) bind(c, name='luaopen_Neuronet')
        
            type(c_ptr), intent(in), value :: l
            integer(kind = c_int) :: luaopen_Neuronet
            integer*8 n 
            n = 13
            call lua_pushinteger(l, n)
            ! call lua_setglobal(l, 'a')
            luaopen_Neuronet = 1
            return
        end function luaopen_Neuronet
end