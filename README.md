# multi-storey-facility-planning-tool
This MATLAB script uses Gurobi to assign operational resources (ORs) to floors in a multi-storey-facility, in a two-step process:
1. Groups of ORs are formed
2. OR groups are assigned to floors

# Installation and Usage
## Requirements
- MATLAB R2018b (older version probably work, too)
- Gurobi Optimizer with MATLAB interface 

## Installation
Just clone or download and unzip this repository to a location of your choice. 

## Usage
Make adjustments to the `loadInput.m` file and run `main.m`.

### Input files
This script requires two input files in CSV format located in the `input` directory. I included sample files which can be used a templates. The first file (here `sample_areas.csv`) contains the area requirements of the ORs. The second file (here `sample_transports.csv`) contains the transport volumes (unit of quantity per unit of observation period) of pairwise transports between ORs, in the form of a transport matrix. The rows represent sources and the columns represent sinks. Rows and columns of the transport matrix are interpreted in the same order as the specified area requirements. For instance, OR 10 has an area requirement of 200 units. Transport volumes from OR 10 to any other OR are listed in row 10 and transport volumes to OR 10 from any other OR are listed in column 10 of the transport matrix.

### Settings
For specific settings and boundary conditions, please refer to the code comments in `loadInput.m`.

### Output files
The script generates two separate output files located in `results`. The results of step 1 are stored in `OR_assignments.csv`. Row i represents OR i (same order as in input files) and column j represents group j. An entry of 1 means that OR i has been assigned to group j. The objective function maximizes the transport volumes of all transports that are contained within a group and thus minimizes inter-group transports. Gurobi's B&B algorithm guarantees optimality. Note that a group might be empty if it's not needed. 

The results of step 2 are stored in `floor_order.csv`. The entries of the "InitialFloor" column correspond to the group index j of result 1. The "TargetFloor" column indicates the target floor # of group j. The objective function of step 2 minimizes the sum of all transport intensities (transport volume x distance) of inter-floor-transports. Again, optimality is guaranteed.
