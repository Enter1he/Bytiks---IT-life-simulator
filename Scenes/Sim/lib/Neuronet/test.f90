module funcs
    type elm
        class(*), allocatable :: value
    end type

    
    contains
    function create(v,len, init) result(res)
        type(elm), pointer :: res(:)
        class(*) :: v
        integer, optional :: len
        class(*), optional :: init
        if (.not. present(len)) len = 1
        
        allocate(res(len))
        do i = 1, len
            allocate(res(i)%value, mold=v)
        enddo
    end
    subroutine set_i(a, i, v)
        type(elm), pointer :: a(:)
        integer :: i
        class(*), intent(in) :: v
        if (allocated(a(i)%value)) then
            a(i)%value = v
        else
            allocate(a(i)%value, source=v)
        endif
    end
end

program test
    use dyn_Array
    implicit none
    
    class(Array), allocatable :: a
    a = Array(1,2,3)
    
    print *, transfer(a%get_i(1), 1)
end

