
#include <sourcemod>

#define PLUGIN_VERSION "1.0.0"


public Plugin myinfo =
{
	name = "AbNeR Map Lister",
	author = "abnerfs",
	description = "Maplister that supports Workshop maps",
	version = PLUGIN_VERSION,
	url = "https://github.com/abnerfs/"
}

public void OnPluginStart() {
    CreateConVar("abner_maplister_version", PLUGIN_VERSION, "Plugin Version", FCVAR_NOTIFY|FCVAR_REPLICATED);
    RegAdminCmd("sm_maplist", Command_ListMaps, ADMFLAG_GENERIC, "Prints a map list satisfying the optionally specified filter to the user that executed the command");
    RegAdminCmd("sm_writemaplist", Command_WriteMapList, ADMFLAG_GENERIC, "Outputs a map list satisfying the optionally specified filter to the file specified.");
}


stock void ListMaps(int client, const char[] filter, char[] path) {
    bool writeFile = !StrEqual(path, "");

    PrintToServer("Filter %s", filter);
    ArrayList list = MapLister("maps", filter);

    for(int i = 0; i < list.Length;i++) {
        char strMap[500];
        list.GetString(i, strMap, sizeof(strMap));
        if(writeFile)
            continue;

        ReplyToCommand(client, strMap);
    }

    if(writeFile) {
        WriteMapFile(path, list);
        ReplyToCommand(client, "Sucessfully saved file %s", path);
    }
}

public Action Command_ListMaps(int client, int args) {
    char szFilter[30];
    if(args > 0) {
        GetCmdArg(1, szFilter, sizeof(szFilter));
    }

    ListMaps(client, szFilter, "");

}


public Action Command_WriteMapList(int client, int args) {
   
    char path[PLATFORM_MAX_PATH];
    GetCmdArg(1, path, sizeof(path));

    if(args < 1) {
        ReplyToCommand(client, "sm_writemaplist <Path> <filter: optional>");
    }

    char szFilter[30];
    if(args > 1) {
        GetCmdArg(2, szFilter, sizeof(szFilter));
    }

    ListMaps(client, szFilter, path);
    ReplyToCommand(client, "Sucessfully saved file %s", path);
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
}



public ArrayList MapLister(const char[] path, const char[] szFilter) {

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
            if(StrContains(mapBuffer, ".bsp") > -1 && (StrEqual(szFilter, "") || StrContains(mapBuffer, szFilter) == 0 ) ){
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
            ArrayList listArr = MapLister(mapBuffer, szFilter);
            for(int i = 0; i < listArr.Length; i++) {
                char strMap[PLATFORM_MAX_PATH];
                listArr.GetString(i, strMap, sizeof(strMap));
                list.PushString(strMap);
            }
        }
    } 
    return list;
}
