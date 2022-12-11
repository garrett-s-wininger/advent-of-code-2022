program main
  implicit none
  
  character(len=256) :: path
  character(len=:), allocatable :: datastream
  integer :: fsize, fu, i, ios, j, k
  logical :: duplicate

  if (command_argument_count() /= 1) then
    stop "Usage: ./main <filepath>"
  end if

  call get_command_argument(1, path)

  open(access="stream", form="unformatted", file=path, iostat=ios, &
       status="old", action="read", newunit=fu)
  
  if (ios /= 0) then
    stop "Could not open requested file"
  end if

  inquire(unit=fu, size=fsize)
  allocate(character(len=fsize) :: datastream)

  read(unit=fu, iostat=ios) datastream
  
  if (ios /= 0) then
    stop "Could not read file contents"
  end if

  do i = 1, fsize - 4
    duplicate = .FALSE.

    do j = 0, 3
      do k = 0, 3
        if (j == k) cycle
        
        if (datastream(i+j:i+j) == datastream(i+k:i+k)) then
          duplicate = .TRUE.
        end if    
      end do
    end do

    if (duplicate .eqv. .FALSE.) then
      print "(*(G0))", "Marker found at character ", i + 3, ": ", datastream(i:i+3)
      exit
    end if
  end do

  close(9)

end program main

