// Hello World

#include <iostream>
#include <fstream>
#include <list>

using namespace std;

int main(int argc, char* argv[]) 
{
    list<int> l;

    for(int i=1; i<=10; ++i)
    {
        l.push_back(i);
    }

    ofstream fo;
    fo.open("file.txt");
    for(auto i : l)
    {
        cout << i << endl;
        fo << i*i << endl;
    }
    fo.close();

    ifstream fi;
    string line;
    fi.open("file.txt");
    while(getline(fi, line))
    {   
        int i = atoi(line.c_str());
        cout << i << endl;
    }

    return 0;
}