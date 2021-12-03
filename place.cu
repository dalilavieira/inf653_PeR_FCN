%%gpu 

#include <iostream>
#include <fstream>
#include <vector>
#include <string>
#include <cstdlib>
#include <ctime>
#include <math.h>

#include<stdio.h>
#include<stdlib.h> 


using namespace std;


int n_vertex = 0;
int n_edge = 0;
vector <pair <int,int>> edges_list;

__global__ void hello(int *a, int *b, int *c, int* d) {
  printf("Hello World! \n");
}

int read_file(string filename){
    ifstream indata;
    indata.open(filename);
 
    if (!indata) {
        cerr << "Could not open the file - '"
             << filename << "'" << endl;
        return EXIT_FAILURE;
    }
 
    int a, b;
    int i = 0;
    pair <int, int> p;
 
    while (indata >> a >> b){
        if (i == 0){
          n_vertex = a;
          n_edge = b;
        }else{
            p = make_pair(a, b);
            edges_list.push_back(p);
        }
        i ++;
    }
 
    cout << n_edge << " " << n_vertex << endl;
   /* for (int i=0; i<edges_list.size(); i++){
        cout << edges_list[i].first << endl;
    }*/

    indata.close();
    return EXIT_SUCCESS;
}


int main()
{
  

    srand(time(0));
    string filename("/content/inf653_PeR_FCN/chebyshev.in");
    read_file(filename);
    
    int size_g = int(pow(n_vertex,0.5)*1.7);
    
    // STARTING THE GPU CODE
    int *adj, *loc, *gridplace, *out;
    int *d_adj, *d_gridplace, *d_out, *d_loc; // device copies of a, b, c
    int threads_per_block=0, no_of_blocks=0;
 
    // Alloc space for host copies of a, b, c and setup input values
    adj = (int *)malloc(n_vertex*n_vertex*sizeof(int)); 
    loc = (int *)malloc(2*n_vertex*sizeof(int)); 
    gridplace = (int *)malloc(size_g*size_g*sizeof(int));
    out = (int *)malloc(size_g*sizeof(int));
 
    for (int i=0; i<n_vertex; i++)  
      for (int j=0; j<n_vertex; j++)
        adj[i*n_vertex+j] = 0; //adj_matrix[i][j] = 0;
 
    int a, b;
    for (int i=0; i<edges_list.size(); i++){
      a = edges_list[i].first;
      b = edges_list[i].second;
      adj[a*n_vertex+b] = 1;
    }
 
    cout << "Print: adj matrix" << endl;
    for (int i=0; i<n_vertex; i++) { 
      for (int j=0; j<n_vertex; j++)
        cout <<  adj[i*n_vertex+j] << " ";
      cout << endl;
    }
    cout << endl;

    for (int i=0; i<size_g; i++)
      for (int j=0; j<size_g; j++)
        gridplace[i*size_g+j] = -1;

    int x,y;
   // x = rand()%(size_g);
    for (int i=0; i<n_vertex; i++){
        do{
          x = rand()%(size_g);
          y = rand()%(size_g);
        }while(gridplace[x*size_g+y] != -1);

        gridplace[x*size_g+y] = i;
        gridplace[x*size_g+y] = i;
        loc[i*2] = x;
        loc[i*2+1] = y;
     //   cout << i << " " << x << " " << y << endl;
    }
 
    cout << "Print: vertex loc in grid" << endl;
    for (int i=0; i<n_vertex; i++)
      cout << i << " " <<  loc[i*2] << " " << loc[i*2+1] << endl;
    cout << endl;
 

    //GPUT stuff
     // Alloc space for device copies of a, b, c
    cudaMalloc((void **)&d_adj, n_vertex*n_vertex*sizeof(int));
    cudaMalloc((void **)&d_loc, 2*n_vertex*sizeof(int));
    cudaMalloc((void **)&d_gridplace, size_g*size_g*sizeof(int));
    cudaMalloc((void **)&d_out, size_g*sizeof(int));

    // Copy inputs to device
    cudaMemcpy(d_adj, adj, n_vertex*n_vertex*sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(d_loc, loc, n_vertex*2*sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(d_gridplace, gridplace, size_g*size_g*sizeof(int), cudaMemcpyHostToDevice);

    threads_per_block = 512;
    no_of_blocks = size_g/threads_per_block;	
   // device_add<<<no_of_blocks,threads_per_block>>>(d_adj,d_loc,d_gridplace);
    
    cudaDeviceSynchronize();
    hello<<<1,1>>>(d_adj, d_loc, d_gridplace, d_out);
    cudaDeviceSynchronize();

    // Copy result back to host
    cudaMemcpy(out, d_out, size_g, cudaMemcpyDeviceToHost);

}
