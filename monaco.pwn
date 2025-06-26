// Monaco-RP-VIP-Edition by LWSEF_01

#include <a_samp>
#include <a_mysql>
#include <sscanf2>
#include <zcmd>

#define MYSQL_HOST     "127.0.0.1"
#define MYSQL_USER     "root"
#define MYSQL_PASSWORD ""
#define MYSQL_DATABASE "samp"

new mysql;

new PlayerJob[MAX_PLAYERS];
new PlayerVIP[MAX_PLAYERS];
new PlayerAdmin[MAX_PLAYERS];
new PlayerLogged[MAX_PLAYERS];

public OnGameModeInit()
{
    mysql = mysql_connect(MYSQL_HOST, MYSQL_USER, MYSQL_PASSWORD, MYSQL_DATABASE);
    if(mysql_errno() != 0) print("MySQL connection failed!");
    else print("MySQL connection successful.");

    return 1;
}

public OnPlayerConnect(playerid)
{
    PlayerJob[playerid] = 0;
    PlayerVIP[playerid] = 0;
    PlayerAdmin[playerid] = 0;
    PlayerLogged[playerid] = 0;
    return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
    if(PlayerLogged[playerid] == 1)
    {
        new query[256];
        mysql_format(mysql, query, sizeof(query),
            "UPDATE players SET job = %d, vip_level = %d, admin_level = %d WHERE username = '%e'",
            PlayerJob[playerid], PlayerVIP[playerid], PlayerAdmin[playerid], GetName(playerid));
        mysql_query(mysql, query);
    }
    return 1;
}

stock GetName(playerid)
{
    new name[MAX_PLAYER_NAME];
    GetPlayerName(playerid, name, sizeof(name));
    return name;
}CMD:login(playerid, params[])
{
    new password[32];
    if(sscanf(params, "s[32]", password)) return SendClientMessage(playerid, -1, "/login [كلمة المرور]");
    
    new query[128];
    mysql_format(mysql, query, sizeof(query), "SELECT * FROM players WHERE username = '%e' AND password = '%e'", GetName(playerid), password);
    mysql_tquery(mysql, query, "OnLoginResponse", "i", playerid);
    return 1;
}

forward OnLoginResponse(playerid);
public OnLoginResponse(playerid)
{
    if(cache_num_rows() > 0)
    {
        PlayerJob[playerid] = cache_get_field_content_int(0, "job");
        PlayerVIP[playerid] = cache_get_field_content_int(0, "vip_level");
        PlayerAdmin[playerid] = cache_get_field_content_int(0, "admin_level");
        PlayerLogged[playerid] = 1;

        if(strcmp(GetName(playerid), "LWSEF_01", true) == 0)
        {
            PlayerAdmin[playerid] = 10;
            PlayerVIP[playerid] = 3;
            SendClientMessage(playerid, 0xFFD700FF, "👑 مرحباً بك LWSEF_01، مالك السيرفر!");
        }

        SendClientMessage(playerid, -1, "✅ تم تسجيل الدخول بنجاح.");
    }
    else SendClientMessage(playerid, -1, "❌ اسم المستخدم أو كلمة المرور غير صحيحة.");
    return 1;
}// أوامر إدارية

CMD:setadmin(playerid, params[])
{
    if(PlayerAdmin[playerid] < 10) return SendClientMessage(playerid, -1, "🚫 ليس لديك صلاحيات.");
    new id, level;
    if(sscanf(params, "ii", id, level)) return SendClientMessage(playerid, -1, "/setadmin [id] [level]");
    PlayerAdmin[id] = level;

    new query[128];
    mysql_format(mysql, query, sizeof(query), "UPDATE players SET admin_level = %d WHERE username = '%e'", level, GetName(id));
    mysql_query(mysql, query);

    SendClientMessage(playerid, -1, "✅ تم تعيين رتبة الأدمن.");
    return 1;
}

CMD:kick(playerid, params[])
{
    if(PlayerAdmin[playerid] < 1) return SendClientMessage(playerid, -1, "🚫 ليس لديك صلاحيات.");
    new id;
    if(sscanf(params, "i", id)) return SendClientMessage(playerid, -1, "/kick [id]");
    Kick(id);
    SendClientMessage(playerid, -1, "✅ تم طرد اللاعب.");
    return 1;
}

CMD:viphelp(playerid, params[])
{
    if(PlayerVIP[playerid] == 0) return SendClientMessage(playerid, -1, "❌ أنت لست VIP.");
    SendClientMessage(playerid, 0x00FFFFAA, "🛠️ أوامر VIP: /vipcar /vipskin /vipcolor");
    return 1;
}
