/*
 *  dpcore.c
 *  Core of dynamic programming/DTW calculation
 * 2003-04-02 dpwe@ee.columbia.edu
 * $Header: /Users/dpwe/projects/dtw/RCS/dpcore.c,v 1.4 2009/07/27 22:54:53 dpwe Exp $
% Copyright (c) 2003-05 Dan Ellis <dpwe@ee.columbia.edu>
% released under GPL - see file COPYRIGHT
 */
 
#include    <stdio.h>
#include    <math.h>
#include    <ctype.h>
#include    "mex.h"

/* #define DEBUG */

/* #define INF HUGE_VAL */
#define INF DBL_MAX

void
mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    int 	i,j;
    long   	pvl, pvb[16];

#ifdef DEBUG
    mexPrintf("dpcore: Got %d lhs args and %d rhs args.\n", 
	      nlhs, nrhs); 
    for (i=0;i<nrhs;i++) {
	mexPrintf("RHArg #%d is size %d x %d\n", 
		  (long)i, mxGetM(prhs[i]), mxGetN(prhs[i]));
    }
    for (i=0;i<nlhs;i++)
	if (plhs[i]) {
	    mexPrintf("LHArg #%d is size %d x %d\n", 
		      (long)i, mxGetM(plhs[i]), mxGetN(plhs[i]));
	}
#endif /* DEBUG */

    if (nrhs < 1){
	mexPrintf("dpcore  [D,P] = dpcore(S[,C])  dynamic programming core\n");
	mexPrintf("           Calculate the best cost to every point in score\n");
	mexPrintf("           cost matrix S; return it in D along with traceback\n");
	mexPrintf("           indices in P. Optional C defines allowable steps\n");
	mexPrintf("           and costs; default [1 1 1.0;1 0 1.0;0 1 1.0]\n");
	return;
    }

    if (nlhs > 0){
	mxArray  *DMatrix, *PMatrix;
	int rows, cols, i, j, k, tb;
	double *pM, *pD, *pP, *pC;
	double d1, d2, d3, v;
	double *costs;
	int *steps;
	int ncosts;

	rows = mxGetM(prhs[0]);
	cols = mxGetN(prhs[0]);
	pM = mxGetPr(prhs[0]);

	DMatrix = mxCreateDoubleMatrix(rows, cols, mxREAL);
	pD = mxGetPr(DMatrix);
	PMatrix = mxCreateDoubleMatrix(rows, cols, mxREAL);
	pP = mxGetPr(PMatrix);
	plhs[0] = DMatrix;
	if (nlhs > 1) {
	    plhs[1] = PMatrix;
	}

	/* setup costs */
	if (nrhs == 1) {
	    /* default C matrix */
	    int ii;

	    ncosts = 3;
	    costs = (double *)malloc(ncosts*sizeof(double));
	    for (ii = 0; ii<ncosts; ++ii) costs[ii] = 1.0;
	    steps = (int *)malloc(ncosts*2*sizeof(int));
	    steps[0] = 1;	steps[1] = 1;
	    steps[2] = 1;	steps[3] = 0;
	    steps[4] = 0;	steps[5] = 1;
	} else {
	    int ii, crows, ccols;
	    crows = mxGetM(prhs[1]);
	    ccols = mxGetN(prhs[1]);
	    pC = mxGetPr(prhs[1]);
	    /* mexPrintf("C has %d rows and %d cols\n", crows, ccols); */
	    if (ccols != 3) {
		mexPrintf("Cost matrix must have 3 cols (i step, j step, cost factor)\n");
		return;
	    }
	    ncosts = crows;
	    costs = (double *)malloc(ncosts*sizeof(double));
	    steps = (int *)malloc(ncosts*2*sizeof(int));
	    for (ii = 0; ii < ncosts; ++ii) {
		steps[2*ii] = (int)(pC[ii]);
		steps[2*ii+1] = (int)(pC[ii+crows]);
		costs[ii] = pC[ii+2*crows];
		/* mexPrintf("step=%d,%d cost=%f\n", steps[2*ii],steps[2*ii+1],costs[ii]); */
	    }
	}


	/* do dp */
	v = 0;	
	tb = 1;	/* value to use for 0,0 */
	for (j = 0; j < cols; ++j) {
	    for (i = 0; i < rows; ++i) {
		d1 = pM[i + j*rows];
		for (k = 0; k < ncosts; ++k) {
		    if ( i >= steps[2*k] && j >= steps[2*k+1] ) {
			d2 = costs[k]*d1 + pD[(i-steps[2*k]) + (j-steps[2*k+1])*rows];
			if (d2 < v) {
			    v = d2;
			    tb = k+1;
			}
		    }
		}

		pD[i + j*rows] = v;
		pP[i + j*rows] = (double)tb;
		v = INF;
	    }
	}
	free((void *)costs);
	free((void *)steps);
    }

#ifdef DEBUG
    mexPrintf("dpcore: returning...\n");
#endif /* DEBUG */
}

