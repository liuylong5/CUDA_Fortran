module simpleOps_m

    contains

    attributes(global) subroutine increment(a, b)

        implicit none

        integer , intent(inout) :: a(:)
        integer , value :: b
        integer :: i, n

        i = blockDim%x*(blockIdx%x-1) + threadIdx%x
        n = size(a)
        if (i <= n) a(i) = a(i)+b

    end subroutine increment

end module simpleOps_m


program incrementTest

    use cudafor
    use simpleOps_m

    implicit none

    integer , parameter :: n = 1024*1024
    integer , allocatable :: a(:)
    integer , device , allocatable :: a_d(:)
    integer :: b, tPB = 256

    allocate(a(n), a_d(n))
    a = 1
    b = 3

    a_d = a
    call increment <<<ceiling(real(n)/tPB),tPB >>>(a_d , b)
    a = a_d

    if (any(a /= 4)) then
        write(*,*) '**** Program Failed ****'
    else
        write(*,*) 'Program Passed'
    endif
    deallocate(a, a_d)

end program incrementTest
