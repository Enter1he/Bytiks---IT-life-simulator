module dyn_Array
    implicit none
    private
    type, public :: Elem
        class(*), allocatable :: value
    end type

    type, public :: Array
        private
        type(Elem), pointer :: data(:)
        integer :: free = 0
        class(*), allocatable :: typev
        contains
        procedure :: del_exchg  => del_exchg
        procedure :: push_back => push_back
        procedure :: get_i => get_i
        procedure :: set_i => set_i
        procedure :: get_last => get_last
        procedure :: get_vacant => get_vacant
        procedure :: get_free => get_free
    end type

    interface Array
        procedure :: ctor
    end interface
    
    contains
        function ctor(v, len, init)
            class(Array), allocatable :: ctor
            class(*), intent(in) :: v
            integer, optional :: len
            class(*), optional :: init
            
            integer :: i
            
            allocate(ctor)
            allocate(ctor%typev, source=v)
            if (.not. present(len)) len = 1
            allocate(ctor%data(len))
            do i = 1, len 
                allocate(ctor%data(i)%value, mold=v)
                if (present(init)) then 
                    if (same_type_as(init, v)) ctor%data(i)%value = init
                endif
            enddo
            
        end

        subroutine push_back(a, v)
            class(Array), intent (inout) :: a
            class(*), intent(in) :: v
            type(Elem), pointer :: b(:)

            integer :: i

            if (.not. same_type_as(a%typev, v)) then
                print*, 'push_back value should be same type as array'
                error stop
            endif

            i = size(a%data)-a%free
            if (a%free > 0) then
                a%free = a%free - 1
                i = size(a%data)-a%free
                a%data(i)%value = v
                return
            endif
            allocate(b(size(a%data)+1))
            b = a%data
            deallocate(a%data)
            a%data => b
        end

        subroutine set_i(a, i, v)
            class(Array), intent(inout) :: a
            integer :: i
            class(*) :: v

            a%data(i)%value = v
        end

        function get_i(a, i)
            class(*), allocatable :: get_i
            class(Array), intent(inout) :: a
            integer :: i
            
            get_i = a%data(i)%value
        end

        function get_last(a)
            class(*), allocatable :: get_last
            class(Array), intent(inout) :: a

            get_last = a%data(size(a%data)-a%free)%value
        end

        integer function get_free(a)
            class(Array), intent(inout) :: a

            get_free = a%free
        end
        
        integer function get_vacant(a)
            class(Array), intent(inout) :: a

            get_vacant = size(a%data) - a%free
        end

        subroutine del_exchg(a, i)
            class(Array), intent(inout) :: a
            integer, intent(in) :: i

            a%data(i) = a%data(size(a%data)-a%free)
            a%free = a%free + 1
        end
end