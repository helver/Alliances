#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>

#define NUM_PARTITIONS 50

struct data_set {
    float x;
    float y;
};

struct data_file {
    double maxx;
    double toty;
    int lines;
    struct data_set *points;
    char *filename;
    FILE* fil;
};

char *colors[6] = { "white", "red", "green", "blue", "magenta", "cyan"};
int cur_color = 0;

int debug = 0;
int partitions = NUM_PARTITIONS;

double jpd(double max1, double max2, double p1, double p2);
double combo(double n, double r);
double range_comp(struct data_file *one, struct data_file *two, int top, int bot);
void do_correlation(FILE *xf2, FILE *sf2, struct data_file[2]);
void do_up_data_file(FILE* xf1, FILE* xf2, struct data_file *dat, int j);
void setup_data_file(FILE* tf1, FILE* sf2, struct data_file *dat, char *filename);
int gcd(int m, int n);
int lcm(int i, int j);
void scale(struct data_file data[2]);
void acquire_points(FILE *tf1, struct data_file *dat, int j);


FILE * open_singleplot_outfile(char * infile)
{
    FILE * fil;
    char filename[128];
    char *runner = NULL;
    char *file = NULL;
    char *label = NULL, *units = NULL;
    char xplthdr[256];

    file = (char *)strdup(infile);

    if((runner = strchr(file, '/')) == NULL) {
	printf("Invalid input filename.  Expected filename looks like:  1234567890/data/xxxxx.xxx\n");
	printf("open singleplot first check - infile %s\n", infile);
	exit(1);
    }

    *runner = '\0';
    runner++;

    if((runner = strchr(runner, '/')) == NULL) {
	printf("Invalid input filename.  Expected filename looks like:  1234567890/data/xxxxx.xxx\n");
	printf("open singleplot second check - infile %s\n", infile);
	exit(1);
    }

    runner++;

    sprintf(filename, "%s.%s.xplt", runner, file);

    if(strstr(runner, "size")) {
	units = "bytes";
	label = "Transfer Size in bytes";
    } else {
	units = "ms";
	label = "Time in ms";
    }

    sprintf(xplthdr, "double double\ntitle\n%s\nxlabel\n%s\nylabel\nFraction of connections\nxunits\nlog %s\n",
	    infile, label, units);

    if((fil = fopen(filename, "w")) == NULL) {
	printf("Unable to open output file %s.\n", filename);
	exit(1);
    }

    fprintf(fil, "%s", xplthdr);

    return fil;
}




    
FILE * open_doubleplot_outfile(char *infile1, char *infile2)
{
    FILE * fil;
    char filename[128];
    char *runner1 = NULL;
    char *file1 = NULL;
    char *runner2 = NULL;
    char *file2 = NULL;
    char xplthdr[512];
    char *units = NULL, *label = NULL;

    file1 = (char *)strdup(infile1);

    if((runner1 = strchr(file1, '/')) == NULL) {
	printf("Invalid input filename.  Expected filename looks like:  1234567890/data/xxxxx.xxx\n");
	printf("open doubleplot - infile1 %s\n", infile1);
	exit(1);
    }

    *runner1 = '\0';

    file2 = (char *)strdup(infile2);

    if((runner2 = strchr(file2, '/')) == NULL) {
	printf("Invalid input filename.  Expected filename looks like: 1234567890/data/xxxxx.xxx \n");
	printf("open doubleplot - infile2 %s\n", infile1);
	exit(1);
    }

    *runner2 = '\0';

    runner2++;

    if((runner1 = strchr(runner2, '/')) == NULL) {
	printf("Invalid input filename.  Expected filename looks like: 1234567890/data/xxxxx.xxx \n");
	exit(1);
    }

    runner1++;

    sprintf(filename, "%s.%s.vs.%s.xplt", runner1, file1, file2);

    if(strstr(runner1, "size")) {
	units = "bytes";
	label = "Transfer Size in bytes";
    } else {
	units = "ms";
	label = "Time in ms";
    }

    sprintf(xplthdr, "double double\ntitle\n%s vs %s\nxlabel\n%s\nylabel\nFraction of connections\nxunits\n%s\n",
	    file1, file2, label, units);

    if((fil = fopen(filename, "w")) == NULL) {
	printf("Unable to open output file %s.\n", filename);
	exit(1);
    }

    fprintf(fil, "%s", xplthdr);

    return fil;
}




    
FILE * open_statistics_outfile(char *infile1, char *infile2)
{
    FILE * fil;
    char filename[128];
    char *runner1 = NULL;
    char *file1 = NULL;
    char *runner2 = NULL;
    char *file2 = NULL;

    file1 = (char *)strdup(infile1);

    if((runner1 = strchr(file1, '/')) == NULL) {
	printf("Invalid input filename.  Expected filename looks like:  1234567890/data/xxxxx.xxx\n");
	printf("open statistics outfile - infile1 %s\n", infile1);
	exit(1);
    }

    *runner1 = '\0';

    file2 = (char *)strdup(infile2);

    if((runner2 = strchr(file2, '/')) == NULL) {
	printf("Invalid input filename.  Expected filename looks like: 1234567890/data/xxxxx.xxx \n");
	printf("open statistics outfile - infile2 %s\n", infile2);
	exit(1);
    }

    *runner2 = '\0';

    runner2++;

    if((runner1 = strchr(runner2, '/')) == NULL) {
	printf("Invalid input filename.  Expected filename looks like: 1234567890/data/xxxxx.xxx \n");
	printf("stats \n");
	exit(1);
    }

    runner1++;

    sprintf(filename, "stats.%s.vs.%s", file1, file2);

    if((fil = fopen(filename, "a")) == NULL) {
	printf("Unable to open output file %s.\n", filename);
	exit(1);
    }

    fprintf(fil, "\n%s data for dumps %s and %s\n", runner1, file1, file2);

    return fil;
}
    




int main(int argc, char **argv)
{
    FILE *tf1 = NULL;
    FILE *xf1 = NULL;
    FILE *xf2 = NULL;
    FILE *sf2 = NULL;
    int i, k;
    char buf[256];
    struct data_file data[2];
    int j;

    if(argc == 1) {
	printf("Not enough arguments to tcplib2xplt.  Expect at least one tcplib data file.\n");
	exit(1);
    }

    if(argc > 3) {
	printf("Too many arguments to tcplib2xplt.  Expect 'tcplib2xplt infile infile'\n");
	exit(1);
    }

    for(i = 0; i < (argc-1); i++) {

	if((tf1 = fopen(argv[i+1], "r")) == NULL) {
	    printf("Unable to open input file %s.\n", argv[i+1]);
	    exit(1);
	}

	setup_data_file(tf1, sf2, &(data[i]), argv[i+1]);

	fseek(tf1, 0, SEEK_SET);
	fgets(buf, 255, tf1);

	j = 0;

	while(!feof(tf1)){
	    acquire_points(tf1, &(data[i]), j);
	    j++;
	}

	fclose(tf1);

    }

    scale(data);

    for(i = 0; i < (argc - 1); i++) {
	cur_color = i;
	xf1 = open_singleplot_outfile(argv[i+1]);

	/* Means we've got three command line arguments, or two
	 * input files.  This means we want to generate both a
	 * double plot file, and a statistics output file */
	if((i == 0) && (argc == 3)) {
	    xf2 = open_doubleplot_outfile(argv[1], argv[2]);

	    sf2 = open_statistics_outfile(argv[1], argv[2]);
	}

	if(xf2) {
	    for(k = 0; pow(10, k) <= data[i].maxx; k++) {
		fprintf(xf2, "line %f %f %f %f blue\n",
			(float)k, 0.0, (float)k, 1.0);
		fprintf(xf2, "rtext %f %f\n%d bytes\n",
			(float)k, 0.5, (int)pow(10, k));
	    }
	}

	for(j = 0; j < data[i].lines; j++)
	    do_up_data_file(xf1, xf2, &(data[i]), j);

	fprintf(xf1, "go\n");
	fclose(xf1);
    }

    if(argc == 3) {
	do_correlation(xf2, sf2, data);
    }
    return 0;
}



void acquire_points(FILE* tf1, struct data_file *dat, int j)
{
    char buf[256];
    char *str = NULL, *nul = NULL;
    int x, y;

    fgets(buf, 255, tf1);

    str = buf;

    if((nul = (char *)strchr(str, '\t')) == NULL)
	return;

    *nul = '\0';

    x = atoi(str);

    str = nul+1;
    if((nul = (char *)strchr(str, '\t')) == NULL) {
	printf("3 Invalid data file format.  Exiting\n");
	return;
    }

    str = nul+1;
    if((nul = (char *)strchr(str, '\t')) == NULL) {
	printf("2 Invalid data file format.  Exiting\n");
	return;
    }

    str = nul+1;
    if((nul = (char *)strchr(str, '\n')) == NULL) {
	printf("1 Invalid data file format.  Exiting\n");
	return;
    }

    *nul = '\0';

    y = atoi(str);

    dat->points[j].x = (float)x;
    dat->points[j].y = (float)y;
}



void do_up_data_file(FILE* xf1, FILE* xf2, struct data_file *dat, int j)
{
    fprintf(xf1, "box %f %f\n", (dat->points[j].x == 0 ? dat->points[j].x : log10(dat->points[j].x)), (dat->points[j].y));

    if(xf2) 
	fprintf(xf2, "box %f %f\n", log10(dat->points[j].x), (dat->points[j].y));

    if(j != 0) {
	fprintf(xf1, "line %f %f %f %f\n", 
		log10(dat->points[j-1].x), 
		(dat->points[j-1].y),
		log10(dat->points[j].x), 
		(dat->points[j].y));

	if(xf2)
	    fprintf(xf2, "line %f %f %f %f %s\n", 
		    log10(dat->points[j-1].x), 
		    (dat->points[j-1].y),
		    log10(dat->points[j].x), 
		    (dat->points[j].y), colors[cur_color]);
    }

}


void setup_data_file(FILE* tf1, FILE* sf2, struct data_file *dat, char *filename)
{
    char buf[256];
    char *lastline = NULL, *str = NULL, *nul = NULL;

    dat->fil = tf1;
    dat->filename = (char *)strdup(filename);

    for(dat->lines = -1; !feof(tf1); dat->lines++) {
	long filepos;

	fgets(buf, 255, tf1);

	if(atoi(buf)) {
	    if(lastline)
		free(lastline);
	    lastline = (char *)strdup(buf);
	}

	filepos = ftell(tf1);
	fseek(tf1, 0, SEEK_END);

	if(filepos > (ftell(tf1) - 5)) {
	    fseek(tf1, filepos, SEEK_SET);
		
	    while(!feof(tf1))
		fgets(buf, 255, tf1);
	} else
	    fseek(tf1, filepos, SEEK_SET);
	    
	if(debug >= 5)
	    printf("Read one line --- %s\n", buf);
    }

    dat->points = (struct data_set *)malloc(sizeof(struct data_set) * dat->lines);

    str = lastline;

    if(str == NULL) { 
	printf("No data for this operation.\n"); 
	if(sf2) {
	    fprintf(sf2, "No data to perform correlation.\n");
	    fclose(sf2);
	}
	exit(1); 
    } 

    if((nul = (char *)strchr(str, '\t')) == NULL) {
	printf("5 Invalid data file format.  Exiting\n");
	exit(1);
    }

    *nul = '\0';
    dat->maxx = atoi(str);

    str = nul+1;
    if((nul = (char *)strchr(str, '\t')) == NULL) {
	printf("6 Invalid data file format.  Exiting\n");
	exit(1);
    }

    str = nul+1;
    if((nul = (char *)strchr(str, '\t')) == NULL) {
	printf("7 Invalid data file format.  Exiting\n");
	exit(1);
    }

    *nul = '\0';
    dat->toty = atoi(str);

    free(lastline);
    lastline = NULL;
}


void scale(struct data_file data[2])
{
    int lcmul, fac0, fac1;
    int i;

    lcmul = lcm(data[0].toty, data[1].toty);

    fac0 = lcmul / data[0].toty;
    fac1 = lcmul / data[1].toty;

    for(i = 0; i < data[0].lines; i++)
	data[0].points[i].y *= fac0;
    
    for(i = 0; i < data[1].lines; i++)
	data[1].points[i].y *= fac1;
}

void do_correlation(FILE *xf2, FILE *sf2, struct data_file data[2])
{
    double datamax, *rctemp;
    double *ptsperpar1, *ptsperpar2;
    double final;
    int i, j;

    fprintf(xf2, "go\n");
    fclose(xf2);

    if(data[0].maxx > data[1].maxx) {
	datamax = data[0].maxx;
    } else {
	datamax = data[1].maxx;
    }

    rctemp = (double *)malloc(partitions * sizeof(double));
    ptsperpar1 = (double *)malloc(partitions * sizeof(double));
    ptsperpar2 = (double *)malloc(partitions * sizeof(double));

    for(i = 0; i < partitions; i++) {
	rctemp[i] = 0;
	ptsperpar1[i] = 0;
	ptsperpar2[i] = 0;
    }

    final = 0;

    for(i = 0; (i < partitions); i++) {
	int temp1, temp2;
	int one_run;

	temp1 = ((datamax/partitions) ? ((i * datamax) / partitions) : i);
	temp2 = ((datamax/partitions) ? (((i + 1) * datamax) / partitions) : i+1);

	rctemp[i] = range_comp(&(data[0]), &(data[1]), temp2, temp1);

	for(j = 0; j < 2; j++) {
	    one_run = 0;

	    while((data[j].points[one_run].x < temp1) && (one_run < data[j].lines))
		one_run++;

	    while(   (one_run < data[j].lines) 
		  && (data[j].points[one_run].x >= temp1) 
		  && (data[j].points[one_run].x < temp2) 
		  && (data[j].points[one_run].x <= data[j].maxx)) {
		if(j == 0)
		    ptsperpar2[i] += data[j].points[one_run].y / data[j].toty; 
		
		if(j == 1)
		    ptsperpar1[i] += data[j].points[one_run].y / data[j].toty; 			

		one_run++;
	    }
	}

	final += rctemp[i] * ptsperpar1[i];
	final += rctemp[i] * ptsperpar2[i];

	if(debug >= 5)
	    printf("range comp return value - %5.2f\n", rctemp[i]);
    }
	
    final /= 2;

    if(debug >= 5)
	printf("Final correlation value %f\n", final);

    fprintf(sf2, "%f\n", final);
}



double range_comp(struct data_file *one, struct data_file *two, int top, int bot)
{
    int i;
    int one_run = 0, two_run = 0;
    int one_count = 0, two_count = 0;
    double topsum = 0, botsum = 0;
    double botsumone = 0, botsumtwo = 0;
    double one_sum = 0, two_sum = 0;
    double one_ave, two_ave;

    for(i = bot; i < top; i++) {
	while(   (one->points[one_run].x < i) 
	      && (one->points[one_run].x <= one->maxx) 
	      && (one_run < one->lines))
	    one_run++;

	while(   (two->points[two_run].x < i) 
	      && (two->points[two_run].x <= two->maxx) 
	      && (two_run < two->lines))
	    two_run++;

	if(one->points[one_run].x == i) {
	    one_count++;
	    one_sum += ((double)one->points[one_run].y);
	}

	if(two->points[two_run].x == i) {
	    two_count++;
	    two_sum += ((double)two->points[two_run].y);
	}
    }

    one_ave = one_sum / (top - bot);
    two_ave = two_sum / (top - bot);

    one_run = two_run = 0;

    for(i = bot; i < top; i++) {
	one_sum = two_sum = 0;

	while(   (one->points[one_run].x < i) 
	      && (one->points[one_run].x < one->maxx) 
	      && (one_run < one->lines))
	    one_run++;

	while(   (two->points[two_run].x < i) 
	      && (two->points[two_run].x < two->maxx) 
	      && (two_run < two->lines))
	    two_run++;

	if(one->points[one_run].x == i) {
	    one_sum = ((double)one->points[one_run].y - one_ave);
	    one_sum *= one_sum;
	}

	if(two->points[two_run].x == i) {
	    two_sum = ((double)two->points[two_run].y - two_ave);
	    two_sum *= two_sum;
	}

	topsum += one_sum * two_sum;

	botsumone += one_sum * one_sum;
	botsumtwo += two_sum * two_sum;
    }

    botsum = sqrt(botsumone * botsumtwo);

    if(debug >= 5)
	printf("%8.5f %8.5f - topsum, botsum\n", topsum, botsum);

    return (botsum == 0 ? 0.0 : (topsum/botsum));
}

double combo(double n, double r)
{
    double num=1;
    double den1=1, den2=1;
    long nn, rr;

//    printf("Combo of %f and %f is\n ", n, r);

    nn = (long)n;
    rr = (long)r;

    if(rr < (nn / 2))
	rr = nn - rr;
	
    while(nn > rr) {
	num *= nn;
	nn--;
    }

    den1 = 1;

    nn = (long)n;

    while((nn - rr) > 1) {
	den2 *= (nn - rr);
	rr++;
    }

//    printf("num - %f, den1 - %f, den2 - %f, den1*den2 - %f\n", num, den1, den2, den1*den2);
    num = (num / (den1 * den2));

//    printf("%f --- den1 - %f  den2 - %f\n", num, den1, den2);

    return num;
}


double jpd(double max1, double max2, double p1, double p2)
{
    double num1, num2;
    double den1;

    num1 = combo(max1, p1);
    num2 = combo(max2, p2);
    den1 = combo((max1 + max2), 2);

    return((num1 * num2)/den1);
}


int gcd(int m, int n)
{
    int t;

    do {
	t = n % m;
	n = m;
	m = t;
    } while (m);

    return n;
}


int lcm(int i, int j)
{
    int temp;
    double di, dj;

    di = (double)i;
    dj = (double)j;

    di = ( fabs(i * j) / gcd(i, j));

    temp = (int)di;

    return temp;
}
