
#include <sourcemod>

public void OnPluginStart() {
    RegConsoleCmd("listmaps", Command_ListMaps);
}

public Action Command_ListMaps(int client, int args) {

    ArrayList list = ReadFolder("maps/");

    for(int i = 0; i < list.Length;i++) {
        char strMap[500];
        list.GetString(i, strMap, sizeof(strMap));
        if(client == 0)
            PrintToServer(strMap);
        else
            PrintToConsole(i, strMap);
    }
    return Plugin_Handled;
}



public ArrayList ReadFolder(const char[] path) {

    ArrayList list = new ArrayList(500);

    if(!DirExists(path))
        return list;

    DirectoryListing dL = OpenDirectory(path);
    char mapBuffer[500];
    FileType typeNext;

    while (dL.GetNext(mapBuffer, sizeof(mapBuffer), typeNext)) {
        if(StrEqual(mapBuffer, ".") || StrEqual(mapBuffer, ".."))
            continue;

        if(typeNext == FileType_File) {
            if(StrContains(mapBuffer, ".bsp") > -1)
                list.PushString(mapBuffer);
        }
        else if(typeNext == FileType_Directory) {
            ArrayList listArr = ReadFolder(mapBuffer);
            for(int i = 0; i < listArr.Length; i++) {
                char strMap[500];
                listArr.GetString(i, strMap, sizeof(strMap));
                list.PushString(strMap);
            }
        }
    } 
    return list;
}
