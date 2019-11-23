
#include <sourcemod>

public void OnPluginStart() {
    RegAdminCmd("listmaps", Command_ListMaps, ADMFLAG_ROOT);
}

public Action Command_ListMaps(int client, int args) {
    ArrayList list = ReadFolder("maps");

    for(int i = 0; i < list.Length;i++) {
        char strMap[500];
        list.GetString(i, strMap, sizeof(strMap));
        if(args > 0)
            continue;

        if(client == 0)
            PrintToServer(strMap);
        else
            PrintToConsole(i, strMap);
    }

    if(args > 0) {
        char path[PLATFORM_MAX_PATH];
        GetCmdArg(1, path, sizeof(path));
        WriteMapFile(path, list);
    }
    

    return Plugin_Handled;
}

WriteMapFile(char[] path, ArrayList list) {
    if(StrContains(path, ".") == -1)
        Format(path, PLATFORM_MAX_PATH, "%s.txt", path);


    Handle file = OpenFile(path, "w");
    for(int i = 0; i < list.Length;i++) {
        char strMap[500];
        list.GetString(i, strMap, sizeof(strMap));
        WriteFileLine(file, strMap);
    }
    CloseHandle(file);
    PrintToServer("Path %s", path);
}



public ArrayList ReadFolder(const char[] path) {

    ArrayList list = new ArrayList(PLATFORM_MAX_PATH);

    if(!DirExists(path))
        return list;

    DirectoryListing dL = OpenDirectory(path);
    char mapBuffer[PLATFORM_MAX_PATH];
    FileType typeNext;

    while (dL.GetNext(mapBuffer, sizeof(mapBuffer), typeNext)) {
        if(StrEqual(mapBuffer, ".") || StrEqual(mapBuffer, ".."))
            continue;

        if(typeNext == FileType_File) {
            if(StrContains(mapBuffer, ".bsp") > -1){
                if(!StrEqual(path, "maps")) {
                    Format(mapBuffer, sizeof(mapBuffer), "%s/%s", path, mapBuffer);
                }

                ReplaceString(mapBuffer, sizeof(mapBuffer), ".bsp", "", false);
                ReplaceString(mapBuffer, sizeof(mapBuffer), "maps/", "", false);
                list.PushString(mapBuffer);
            }
        }
        else if(typeNext == FileType_Directory) {
            Format(mapBuffer, sizeof(mapBuffer), "%s/%s", path, mapBuffer);
            ArrayList listArr = ReadFolder(mapBuffer);
            for(int i = 0; i < listArr.Length; i++) {
                char strMap[PLATFORM_MAX_PATH];
                listArr.GetString(i, strMap, sizeof(strMap));
                list.PushString(strMap);
            }
        }
    } 
    return list;
}
