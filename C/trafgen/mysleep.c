#include <sys/time.h>
#include <stdio.h>
#include <stdlib.h>
#include <sched.h>

int my_sleep(struct timespec *sleep, struct timespec *blah);

int main(int argc, char *argv[])
{
    struct timeval start, stop;
    struct timespec sleepy;
    long sleeplen;
    
    if(argc == 1)
	sleeplen = 5;
    else {
	sleeplen = atoi(argv[1]);
    }

    sleepy.tv_sec = sleeplen / 1000;
    sleepy.tv_nsec = (sleeplen % 1000) * 1000000;

    gettimeofday(&start,(struct timezone *)NULL);

    my_sleep(&sleepy, (struct timespec *)NULL);

    gettimeofday(&stop, (struct tiemzone *)NULL);

    if(start.tv_usec > stop.tv_usec) {
	stop.tv_usec += 1000000;
	stop.tv_sec --;
    }

    printf("Time slept - %ld s, %ld ms\n", stop.tv_sec - start.tv_sec, (stop.tv_usec - start.tv_usec) / 1000);

    return 0;
}

int my_sleep(struct timespec *sleep, struct timespec *blah)
{
    struct timeval now, end;

    gettimeofday(&now, (struct timezone *)NULL);
    end.tv_sec = now.tv_sec + sleep->tv_sec;
    end.tv_usec = now.tv_usec + sleep->tv_nsec / 1000;

    while((((end.tv_sec - now.tv_sec) * 1000000) + (end.tv_usec - now.tv_usec)) > 0) {
	sched_yield();
	gettimeofday(&now, (struct timezone *)NULL);
    }

    return 0;
}
