import heapq
import numpy as np
import matplotlib.pyplot as plt
from matplotlib.colors import ListedColormap
from matplotlib.patches import Patch

def read_maze(filename):
    with open(filename, 'r') as f:
        lines = f.readlines()
    maze = [list(map(int, line.split())) for line in lines]
    return maze

def find_pins(maze):
    pins = []
    for i in range(len(maze)):
        for j in range(len(maze[0])):
            if maze[i][j] == 2:
                pins.append((i, j))
    return pins

def get_neighbors(maze, node):
    i, j = node
    neighbors = []
    for di, dj in [(-1, 0), (1, 0), (0, -1), (0, 1)]:
        ni, nj = i + di, j + dj
        if 0 <= ni < len(maze) and 0 <= nj < len(maze[0]) and maze[ni][nj] != 1:
            neighbors.append((ni, nj))
    return neighbors

# core algorithm for A*
def a_star_search(maze, sources, goals):
    rows, cols = len(maze), len(maze[0])
    goals_set = set(goals)
    
    def h(node):
        if node in goals_set:
            return 0
        return min(abs(node[0] - g[0]) + abs(node[1] - g[1]) for g in goals)
    
    open_list = []
    for source in sources:
        g = 0
        f = h(source)
        heapq.heappush(open_list, (f, g, source))
    
    g_values = {source: 0 for source in sources}
    parents = {source: None for source in sources}
    closed_list = set()
    searched_nodes = set(sources)
    
    while open_list:
        f, g, current = heapq.heappop(open_list)
        if current in goals_set:
            path = []
            while current is not None:
                path.append(current)
                current = parents[current]
            path.reverse()
            return path, searched_nodes
        if current in closed_list:
            continue
        closed_list.add(current)
        for neighbor in get_neighbors(maze, current):
            if neighbor in closed_list:
                continue
            tentative_g = g + 1
            if neighbor not in g_values or tentative_g < g_values[neighbor]:
                g_values[neighbor] = tentative_g
                f = tentative_g + h(neighbor)
                parents[neighbor] = current
                heapq.heappush(open_list, (f, tentative_g, neighbor))
                searched_nodes.add(neighbor)
    return None, searched_nodes

def main():
    # initialization
    maze = read_maze('prob4.txt')
    pins = find_pins(maze)
    if not pins:
        print("no pins found in the maze")
        return
    
    # initial connected pins and unconnected pins
    connected_pins = {pins[0]}
    unconnected_pins = set(pins) - connected_pins
    wires = []
    global_searched_nodes = set()
    
    # A* algorithm to connect all pins
    while unconnected_pins:
        path, searched = a_star_search(maze, connected_pins, unconnected_pins)
        if path is None:
            print("no connection found")
            break
        
        # update connected pins
        pins_on_path = [p for p in path if maze[p[0]][p[1]] == 2]
        for p in pins_on_path:
            if p in unconnected_pins:
                connected_pins.add(p)
                unconnected_pins.remove(p)
        
        # mark the path in the maze
        for p in path:
            if maze[p[0]][p[1]] != 2:
                maze[p[0]][p[1]] = 1
        
        wires.append(path)
        global_searched_nodes |= searched
    
    # output the wires to the file
    with open('wires.txt', 'w') as f:
        for path in wires:
            f.write(' '.join([f'({i},{j})' for i, j in path]) + '\n')
    
    # visualization
    maze = read_maze('prob4.txt')
    rows, cols = len(maze), len(maze[0])
    cmap = ListedColormap(['#FFFFFF', '#4A7A49', '#FF4040'])
    plt.figure(figsize=(10, 10))
    plt.imshow(maze, cmap=cmap, interpolation='none')
    
    # 1.path
    for path in wires:
        js, ks = zip(*[(j, i) for i, j in path])
        plt.plot(js, ks, 'b--', linewidth=3)
    
    # 2.searching area
    searched_array = np.zeros((rows, cols))
    for i, j in global_searched_nodes:
        searched_array[i, j] = 1
    plt.imshow(searched_array, cmap='Blues', alpha=0.3, interpolation='none')

    # 3.grid
    plt.gca().set_xticks(np.arange(-0.5, cols, 1), minor=True)
    plt.gca().set_yticks(np.arange(-0.5, rows, 1), minor=True)
    plt.grid(which='minor', color='black', linewidth=0.5)
    
    plt.title('Routing Result Using A* Algorithm', fontsize=16, fontname='Times New Roman', pad=15)
    plt.xlabel('Column Index', fontsize=12, fontname='Times New Roman')
    plt.ylabel('Row Index', fontsize=12, fontname='Times New Roman')

    legend_elements = [
        Patch(facecolor='#FFFFFF', edgecolor='black', label='Empty Space'),
        Patch(facecolor="#4A7A49", edgecolor='none', label='Obstacle'),
        Patch(facecolor='#FF4040', edgecolor='none', label='Pin'),
        Patch(facecolor='#1F77B4', edgecolor='none', label='Wiring Path'),
        Patch(facecolor="gray", edgecolor='none', alpha=0.5, label='Search Area')
    ]
    plt.legend(handles=legend_elements, loc='upper left', bbox_to_anchor=(1.05, 1), 
            fontsize=10, frameon=True, edgecolor='black', prop={'family': 'Times New Roman'})

    plt.savefig('routing.png')
    plt.show()

if __name__ == '__main__':
    main()