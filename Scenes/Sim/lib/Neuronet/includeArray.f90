
    
    type Array
        private
        class(ARRAY_DATA), pointer :: data(:)
        integer :: free = 0
        contains
        procedure :: del_exchg  
        procedure :: push_back
    end type
    contains
        subroutine push_back(a, v)
            class(Array), intent (inout) :: a
            type(ARRAY_DATA), allocatable intent(inout) :: v
            class(ARRAY_DATA), pointer :: b(:)

            if (a%free > 0) then
                a%data(size(a%data)-a%free) = v
                a%free = a%free - 1
                return
            endif
            allocate(b(size(a%data)+1), source=a%data)
            deallocate(a%data)
            a%data => b
            a%data(size(a%data))%d = v%d
        end
        subroutine del_exchg(a, i)
            class(Array), intent(inout) :: a
            integer, intent(in) :: i
            a%data(i)%d = a%data(size(a%data))%d
            a%free = a%free + 1
        end