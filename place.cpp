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

/*__global__ void print_from_gpu(void) {
	printf("Hello World! from thread [B=%d,T=%d] \
		From GPU device\n", blockIdx.x, threadIdx.x); 
}*/

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
    int *adj, *loc, *gridplace;
    int *d_adj, *d_loc, *d_gridplace; // device copies of a, b, c
    int threads_per_block=0, no_of_blocks=0;

    // Alloc space for host copies of a, b, c and setup input values
    adj = (int *)malloc(n_vertex*n_vertex*sizeof(int)); 
    loc = (int *)malloc(2*n_vertex*sizeof(int)); 
    gridplace = (int *)malloc(size_g*size_g*sizeof(int));


    for (int i=0; i<n_vertex; i++)  
      for (int j=0; j<n_vertex; j++)
        adj[i*n_vertex+j] = -1; //adj_matrix[i][j] = -1;
 
    int a, b;
    for (int i=0; i<edges_list.size(); i++){
      a = edges_list[i].first;
      b = edges_list[i].second;
      adj[a*n_vertex+b] = 1;
      //cout << "aaa"<< edges_list[i].first << " " << edges_list[i].second << endl;
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
        gridplace[i*size_g+j] = 0;

    int x,y;
    for (int i=0; i<n_vertex; i++){
        do{
          x = rand()%(size_g);
          y = rand()%(size_g);
        }while(gridplace[x*size_g+y+1] != 0);

        gridplace[x*size_g+y+1] = i;
        loc[i*n_vertex] = x;
        loc[i*n_vertex+1] = y;
     //   cout << i << " " << x << " " << y << endl;
    }
 
    cout << "Print: vertex loc in grid" << endl;
    for (int i=0; i<n_vertex; i++)
      cout << i << " " <<  loc[i*n_vertex] << " " << loc[i*n_vertex+1] << endl;
    cout << endl;
 
    cout << "Print: placement grid" << endl;
    for (int i=0; i<size_g; i++){
     for (int j=0; j<size_g; j++)
      cout << gridplace[i*size_g+j+1] << " ";
      cout << endl;
    }
 
    //Sai de i e vai pra j
    int origin_x, origin_y;
    int dest_x, dest_y;
    int total = 0;
    for (int i=0; i<n_vertex; i++) { 
      for (int j=0; j<n_vertex; j++)
        if (adj[i*n_vertex+j] == 1){ // tem aresta ligando
            origin_x = loc[i*n_vertex]; //vertex_loc[i][0];
            origin_y = loc[i*n_vertex+1]; //vertex_loc[i][1];
            dest_x = loc[j*n_vertex]; //vertex_loc[j][0];
            dest_y = loc[j*n_vertex+1]; //vertex_loc[j][1];
            total += abs(origin_x - dest_x) + abs(origin_y - dest_y); 
            //cout << cost << endl;
        } 

    }


//    print_from_gpu<<<1,2>>>();
 //   cudaDeviceSynchronize();
       
}
