//==============================================================================
// Author of mod - Nikita Pavlenkov (heazych)
// Website - https://pavlenkoff.ru
// VK group - https://vk.com/heazych
// GitHub - https://github.com/heazych
// When you re-install (modify) the mod, you must specify my authorship!
//==============================================================================
#include <a_samp>
#include <streamer>
#include <a_mysql>
#include <Pawn.CMD>
#include <sscanf2>
//===============================[MySQL]========================================
#define MySQL_HOST	"localhost"
#define MySQL_USER	"root"
#define MySQL_BASE	"base"
#define MySQL_PASS	""
//==============================[������]========================================
#define GAMEMODE	"heazych v0.0.0.1"
#define HOSTNAME	"Server by heazych"
//==============================[Define]========================================
#define	f( 									format(string, sizeof(string),
#define	GN(%1)                              Player[%1][pName]
#define publics%0(%1) forward%0(%1);        public%0(%1)
#define	SPD                                 ShowPlayerDialog
#define DSL                                 DIALOG_STYLE_LIST
#define DSI                                 DIALOG_STYLE_INPUT
#define DSP                                 DIALOG_STYLE_PASS
#define DSM                                 DIALOG_STYLE_MSGBOX
#define SCM                                 SendClientMessage
#define Kickk(%1)							SetTimerEx("kick", 20, false, "i", %1)
//===============================[�����]========================================
#define	COLOR_ASAK              			0xe36565FF
#define COLOR_WHITE             			0xFFFFFFFF
#define COLOR_RED               			0xFF0000FF
//================================[New]=========================================
new dbHandle;
enum pInfo
{
	pName[MAX_PLAYER_NAME],
	pLevel,
	pPass[21],
	pSex,
	pSkin
}
new Player[MAX_PLAYERS][pInfo];
new Login[MAX_PLAYERS];
//==============================[������]========================================
main() return true;
//==============================[Public]========================================
public OnPlayerConnect(playerid)
{
	new string[85];
	GetPlayerName(playerid, Player[playerid][pName], MAX_PLAYER_NAME);
	f("SELECT `Level` FROM `Accounts` WHERE `Name` = '%s'", GN(playerid));
	mysql_function_query(dbHandle, string, true, "PlayerRegition","d", playerid);
	Clear(playerid);
	return true;
}
public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    new string[206];
	switch(dialogid)
	{
	    case 1:
	    {
	        if(response)
	        {
		        if(!strlen(inputtext))
				{
	   				f("{e36565}%s{FFFFFF}, ����� ���������� �� ������!\n\n��� ��� �� ���������������.\n����� ������������������ ������� ���� ������.", GN(playerid));
		    		SPD(playerid, 1, DSI, "����������� ������������", string,"�����","�����");
		    		return true;
				}
				for(new i = strlen(inputtext); i != 0; --i)
				switch(inputtext[i])
				{
				    case '�'..'�', '�'..'�': return SPD(playerid, 1, DSI, "������", "{FFFFFF}������ �� ������ �������� �� ������� ��������.", "�����", "�����");
				}
				if(strlen(inputtext) < 6 || strlen(inputtext) > 20) return SPD(playerid, 1, DSI, "������", "{FFFFFF}������ ������ ��������� �� ����� 6 � �� ����� 20 ��������.\n���������� ������� ������ ������.", "�����", "�����");
				strmid(Player[playerid][pPass], inputtext, 0, strlen(inputtext), 21);
				SPD(playerid, 2, DSM, "��� ���������","{FFFFFF}�������� ��� ������ ���������.","�������","�������");
			}
			else
			{
			    SCM(playerid, COLOR_WHITE, "�� ���� ������� � �������. ��� ������ �������: /q");
	   			Kickk(playerid);
			}
		}
		case 2:
		{
		    if(response)
		    {
				Player[playerid][pSex] = 1;
				Player[playerid][pSkin] = 7; //id �������� �����
		    }
		    else
		    {
		        Player[playerid][pSex] = 2;
		        Player[playerid][pSkin] = 169; //id �������� �����
		    }
			Player[playerid][pLevel] = 1;
			mysql_format(dbHandle, string, sizeof(string), "INSERT INTO `accounts` (`Name`, `Level`, `Skin`, `Sex`, `Password`) VALUES ('%s', '%d', '%d', '%d', '%s')", GN(playerid), Player[playerid][pLevel], Player[playerid][pSkin], Player[playerid][pSex], Player[playerid][pPass]);
			mysql_function_query(dbHandle, string, true, "Registr", "d", playerid);
			Login[playerid] = true;
			SCM(playerid, COLOR_RED, "�� ������� ������������������ �� �������.");
			SpawnPlayer(playerid);
		}
		case 3:
		{
			if(response)
   			{
   			    if(!strlen(inputtext))
   			    {
	    	    	f("{e36565}%s{FFFFFF}, ����� ���������� �� ������!\n\n��� ��� ���������������.\n��� ����������� ������� ���� ������.", GN(playerid));
	    			SPD(playerid, 3, DSI, "�����������", string,"�����","�����");
					return true;
   			    }
   			    mysql_format(dbHandle, string, sizeof(string), "SELECT * FROM `Accounts` WHERE `Name` = '%e' AND `Password` = '%e'", GN(playerid), inputtext);
   			    return mysql_function_query(dbHandle, string, true, "OnLogin", "d", playerid);
   			}
   			else
			{
   				SCM(playerid, COLOR_WHITE, "�� ���� ������� � �������. ��� ������ �������: /q");
	   			Kickk(playerid);
			}
		}
		case 4:
		{
		    	f("���: %s", GN(playerid));
    			SPD(playerid, 8, DSM, "����������", string, "�����", "");
  		}
 	}
	return true;
}
public OnPlayerSpawn(playerid)
{
	SetPlayerSpawn(playerid);
	return true;
}
public OnGameModeInit()
{
    SendRconCommand("hostname "HOSTNAME"");
	SetGameModeText(GAMEMODE);
	DisableInteriorEnterExits();
	EnableStuntBonusForAll(0);
	LimitPlayerMarkerRadius(30.0);
	dbHandle = mysql_connect(MySQL_HOST, MySQL_USER, MySQL_BASE, MySQL_PASS);
	if(mysql_errno(dbHandle) != 0)
	{
		printf("�������� ����������� � ���� ������. ������ #%d", mysql_errno(dbHandle));
	}
	else
	{
		print("����������� � ���� ������ ������ �������!");

		mysql_tquery(dbHandle, "SET CHARACTER SET 'utf8'", "", "");
	    mysql_tquery(dbHandle, "SET NAMES 'utf8'", "", "");
	    mysql_tquery(dbHandle, "SET character_set_client = 'cp1251'", "", "");
	    mysql_tquery(dbHandle, "SET character_set_connection = 'cp1251'", "", "");
	    mysql_tquery(dbHandle, "SET character_set_results = 'cp1251'", "", "");
	    mysql_tquery(dbHandle, "SET SESSION collation_connection = 'utf8_general_ci'", "", "");


	}
	return true;
}
public OnGameModeExit()
{
 	mysql_close(dbHandle);
	return true;
}
public OnPlayerRequestClass(playerid, classid) return true;
public OnPlayerRequestSpawn(playerid) return false; //�������� ������ Spawn
public OnPlayerCommandText(playerid, cmdtext[]) return true;
//==============================[Publics]=======================================
publics kick(playerid)
{
	Kick(playerid);
	return true;
}
publics PlayerRegition(playerid)
{
	new string[206];
 	new rows;
 	new rows2;
 	cache_get_data(rows, rows2);
 	if(rows)
	{
	    f("{e36565}%s{FFFFFF}, ����� ���������� �� ������!\n\n��� ��� ���������������.\n��� ����������� ������� ���� ������.", GN(playerid));
	    SPD(playerid, 3, DSI, "�����������", string,"�����","�����");
	}
	else
	{
	    f("{e36565}%s{FFFFFF}, ����� ���������� �� ������!\n\n��� ��� �� ���������������.\n����� ������������������ ������� ���� ������.", GN(playerid));
	    SPD(playerid, 1, DSI, "����������� ������������", string,"�����","�����");
	}
	return true;
}
publics OnLogin(playerid)
{
	new string[200];
 	new rows;
 	new rows2;
 	cache_get_data(rows, rows2);
 	if(rows)
	{
		cache_get_field_content(0, "Password", Player[playerid][pPass], dbHandle, 21);
		Player[playerid][pLevel] = cache_get_field_content_int(0, "Level");
		Player[playerid][pSkin] = cache_get_field_content_int(0, "Skin");
		Player[playerid][pSex] = cache_get_field_content_int(0, "Sex");
  		Login[playerid] = true;
  		SpawnPlayer(playerid);
  		SCM(playerid, COLOR_WHITE, "�� ������� �������������� �� �������.");
	}
	else
	{
 		f("{e36565}%s{FFFFFF}, ����� ���������� �� ������!\n\n��� ��� ���������������.\n��� ����������� ������� ���� ������.", GN(playerid));
	    SPD(playerid, 3, DSI, "�����������", string,"�����","�����");
	    SCM(playerid, COLOR_RED, "������ ������ �������! {FFFFFF}���������� ������� ������ ������");
	}
	return true;
}
//=============================[Stock]==========================================
stock Registr(i)
{
	new string[128];
	mysql_format(dbHandle, string, sizeof(string), "SELECT * FROM `Accounts` WHERE `Name` = '%e' AND `Password` = '%e'", Player[i][pName], Player[i][pPass]);
	return mysql_function_query(dbHandle, string, true, "OnLogin", "d", i);
}
stock Clear(playerid)
{
	Login[playerid] = false;
}
stock SetPlayerSpawn(playerid)
{
	SetPlayerSkin(playerid, Player[playerid][pSkin]);
	SetPlayerScore(playerid, Player[playerid][pLevel]);
	if(Player[playerid][pLevel] > 0)
	{
	    SetPlayerPos(playerid, 1154.3717, -1770.2594, 16.6000); // ���������� ������.
	    SetPlayerFacingAngle(playerid, 0);
	    SetPlayerInterior(playerid, 0);
	    SetPlayerVirtualWorld(playerid, 0);
	    SetCameraBehindPlayer(playerid);
	}
}
//===========================[������� �������]==================================
CMD:mm(playerid)
{
	SPD(playerid, 4, DSL, "���� ���������", "����������", "�������", "������");
	return true;
}
//==============================================================================
