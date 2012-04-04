c@**********************************************************************
c                                                                      *
c     function dnrm2                                                   *
c                                                                      *
c     given an n-vector dx, this function calculates the               *
c     euclidean norm of dx.                                            *
c                                                                      *
c     the function statement is                                        *
c                                                                      *
c       function dnrm2 (n,dx,inxc)                                     *
c                                                                      *
c     where                                                            *
c                                                                      *
c       n is a positive integer input variable.                        *
c       dx is an input array of length n.                              *
c       incx is the increment                                          *
c                                                                      *
c     four phase method using two build-in constants that are          *
c                                                                      *
c        cutlo = sqrt(u/eps)                                           *
c        cuthi = sqrt(v)                                               *
c     where                                                            *
c        eps = smallest no. such that eps + 1. .gt. 1.                 *
c        u   = smallest positive no. (underflow limit)                 *
c        v   = largest no.           (overflow  limit)                 *
c                                                                      *
c      brief outline of algorithm..                                    *
c                                                                      *
c      phase 1 scans zero components                                   *
c      move to phase 2 when a component is nonzero and .le. cutlo      *
c      move to phase 3 when a component is .gt. cutlo                  *
c      move to phase 4 when a component is .ge. cuthi/m                *
c      where m = n for dx() real and m = 2*n for complex.              *
c                                                                      *
c      in this implementation the values for eps, u and v are given    *
c      in the linpack-function dpmpar                                  *
c                                                                      *
c                                                                      *
c     subprograms called                                               *
c                                                                      *
c       linpack-supplied ... dpmpar                                    *
c       fortran-supplied ... abs,sqrt,dble                             *
c                                                                      *
c     argonne national laboratory. minpack project. march 1980.        *
c     burton s. garbow, kenneth e. hillstrom, jorge j. more            *
c                                                                      *
c     changes 4.4.97                                                   *
c     departement of neurology. rwth aachen. germany.                  *
c     robert p. pohlmeier                                              *
c                                                                      *
c***********************************************************************
      function dnrm2 (n, dx, incx)
c
      integer i,n,incx,nn,j,next
      double precision dx(*),dpmpar,cutlo,hitest,xmax,sum,dnrm2
c
c........for real or d.p. set hitest = cuthi/n
c........for complex      set hitest = cuthi/(2*n)
c........cuthi=sqrt(dpmpar(3))
      hitest = sqrt(dpmpar(3))/dble(n)
      cutlo  = sqrt(dpmpar(2)/dpmpar(1))
c

      if (n .le. 0) then
         dnrm2 = 0.d0
      else
         assign 30 to next
         sum = 0.d0
         nn = n*incx
c
c........begin main loop
c
         i = 1
   20    goto next, (30, 40, 70, 80)
   30    if (abs(dx(i)) .gt. cutlo) goto 110
         assign 40 to next
         xmax = 0.d0
c
c........phase 1. sum is zero
c
   40    if (dx(i) .eq. 0.d0) goto 130
         if (abs(dx(i)) .gt. cutlo) goto 110
c
c........prepare for phase 2.
c
         assign 70 to next
         goto 60
c
c........prepare for phase 4.
c
   50    i = j
         assign 80 to next
         sum = (sum/dx(i))/dx(i)
   60    xmax = abs(dx(i))
         goto 90
c
c........phase 2. sum is small. scale to
c........avoid destructive underflow.
c
   70    if (abs(dx(i)) .gt. cutlo) goto 100
c
c........common code for phases 2 and 4. in
c........phase 4 sum is large. scale to
c........avoid overflow.
c
   80    if (abs(dx(i)) .le. xmax) goto 90
         sum = 1.d0 + sum*(xmax/dx(i))**2
         xmax = abs(dx(i))
         goto 130
c
   90    sum = sum + (dx(i)/xmax)**2
         goto 130
c
c........prepare for phase 3.
c
  100    sum = (sum*xmax)*xmax
c
c........phase 3. sum is mid-range. no
c........scaling.
c
  110    do j=i, nn, incx
            if (abs(dx(j)) .ge. hitest) goto 50
            sum = sum + dx(j)**2
         end do
         dnrm2 = sqrt(sum)
         goto 140
c
  130    continue
         i = i + incx
         if (i .le. nn) goto 20
c
c........end of main loop. compute square
c........root and adjust for scaling.
c
         dnrm2 = xmax*sqrt(sum)
  140    continue
      end if
      return
      end