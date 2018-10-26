
// ------------------------------------
// TASKS / SCHEDULES - 	START
// ------------------------------------
class RCBotTask
{
	bool m_bComplete = false;
	bool m_bFailed = false;
    bool m_bInit = false;

    float m_fTimeout = 0.0f;

    RCBotSchedule@ m_pContainingSchedule;

	void Complete ()
	{
		m_bComplete = true;	
	}

	void Failed ()
	{
		m_bFailed = true;
	}	

    void setSchedule ( RCBotSchedule@ sched )
    {
        @m_pContainingSchedule = sched;
    }

    void init ()
    {
        if ( m_bInit == false )
        {
            m_fTimeout = g_Engine.time + 30.0f;
            m_bInit = true;
        }
        
    }

    bool timedOut ()
    {
        return g_Engine.time > m_fTimeout;
    }

    void execute ( RCBot@ bot )
    {
 
    }
}

class RCBotSchedule
{
	array<RCBotTask@> m_pTasks;
    uint m_iCurrentTaskIndex;

    RCBotSchedule()
    {
        m_iCurrentTaskIndex = 0;
    }

	void addTaskFront ( RCBotTask@ pTask )
	{
        pTask.setSchedule(this);
		m_pTasks.insertAt(0,pTask);
	}

	void addTask ( RCBotTask@ pTask )
	{	
        pTask.setSchedule(this);
		m_pTasks.insertLast(pTask);
	}

	bool execute (RCBot@ bot)
	{        
        if ( m_pTasks.length() == 0 )
            return true;

        RCBotTask@ m_pCurrentTask = m_pTasks[0];

        m_pCurrentTask.init();
        m_pCurrentTask.execute(bot);

        if ( m_pCurrentTask.m_bComplete )
        {                
            BotMessage("m_pTasks.removeAt(0)");
            m_pTasks.removeAt(0);

            if ( m_pTasks.length() == 0 )
            {
                BotMessage("m_pTasks.length() == 0");
                return true;
            }
        }
        else if ( m_pCurrentTask.timedOut() )
        {
            
            m_pCurrentTask.m_bFailed = true;
            // failed
            return true;
        }
        else if ( m_pCurrentTask.m_bFailed )
        {
            return true;
        }

        return false;
	}
}

// ------------------------------------
// TASKS / SCHEDULES - 	END
// ------------------------------------


final class CFindHealthTask : RCBotTask 
{
    CFindHealthTask ( )
    {

    }

    void execute ( RCBot@ bot )
    {
        // Search for health to pick up or health dispenser
        CBaseEntity@ pent = null;

        BotMessage("CFindHealthTask");

        while( (@pent = g_EntityFuncs.FindEntityByClassname(pent, "func_healthcharger")) !is null )
        {
            if ( bot.distanceFrom(pent) < 400 )
            {
                if ( UTIL_IsVisible(bot.m_pPlayer.pev.origin, pent, bot.m_pPlayer ))
                {
                        if ( pent.pev.frame != 0 )
                        {
                            BotMessage("func_healthcharger");

                            // add task to use health charger
                            m_pContainingSchedule.addTask(CUseHealthChargerTask(bot,pent));
                            Complete();
                            return;
                        }
                }
            }
        }
        
        while ( (@pent = g_EntityFuncs.FindEntityByClassname(pent, "item_healthkit")) !is null )
        {
            // within reaching distance
            if ( bot.distanceFrom(pent) < 400 )
            {
                if ( UTIL_IsVisible(bot.m_pPlayer.pev.origin, pent, bot.m_pPlayer ))
                {
                        if ( (pent.pev.effects & EF_NODRAW) != EF_NODRAW )
                        {
                            BotMessage("item_healthkit");
                            // add Task to pick up health
                            m_pContainingSchedule.addTask(CPickupItemTask(bot,pent));
                            Complete();
                            return;
                        }
                }
            }

        }

        
            BotMessage("nothing FOUND");

        Failed();
    }
}

final class CFindAmmoWeaponTask : RCBotTask 
{
    CFindAmmoWeaponTask ( )
    {

    }

    void execute ( RCBot@ bot )
    {
        // Search for health to pick up or health dispenser
        CBaseEntity@ pent = null;

        BotMessage("CFindAmmoWeaponTask");
        
        while ( (@pent = g_EntityFuncs.FindEntityInSphere(pent, bot.m_pPlayer.pev.origin, 512,"weapon_*", "classname" )) !is null )
        {
            if ( (pent.pev.effects & EF_NODRAW) != EF_NODRAW )
            {
      
                if ( bot.m_pPlayer.HasNamedPlayerItem(pent.GetClassname()) is null )
                {
                    if ( UTIL_IsVisible(bot.origin(),pent,bot.m_pPlayer) )
                    {


                        BotMessage(pent.GetClassname());	
                        m_pContainingSchedule.addTask(CPickupItemTask(bot,pent));
                        Complete();
                        return;                    
                    }
                }
            }						
        }

BotMessage("NADA");

        Failed();
        return;
    }
}

final class CFindArmorTask : RCBotTask 
{
    CFindArmorTask ( )
    {

    }

    void execute ( RCBot@ bot )
    {
        // Search for health to pick up or health dispenser
        CBaseEntity@ pent = null;

        BotMessage("CFindArmorTask");

        while ( (@pent = g_EntityFuncs.FindEntityByClassname(pent, "func_recharge")) !is null )
        {
            // within reaching distance
            if ( bot.distanceFrom(pent) < 400 )
            {
                if ( UTIL_IsVisible(bot.m_pPlayer.pev.origin, pent, bot.m_pPlayer ))
                {
                    if ( pent.pev.frame != 0 )
                    {
                        BotMessage("func_recharge");

                        // add task to use health charger
                        m_pContainingSchedule.addTask(CUseArmorCharger(bot,pent));
                        Complete();
                        return;
                    }                    
                }
            }
        }
        
        while ( (@pent = g_EntityFuncs.FindEntityByClassname(pent, "item_battery")) !is null )
        {

            
            // within reaching distance
            if ( bot.distanceFrom(pent) < 400 )
            {
                if ( UTIL_IsVisible(bot.m_pPlayer.pev.origin, pent, bot.m_pPlayer ))
                {
                        if ( (pent.pev.effects & EF_NODRAW) != EF_NODRAW )
                        {
                            BotMessage("item_battery");
                            // add Task to pick up health
                            m_pContainingSchedule.addTask(CPickupItemTask(bot,pent));
                            Complete();
                            return;
                        }                
                }
            }
            
        }

        BotMessage("nothing FOUND");

        Failed();
    }
}

final class CPickupItemTask : RCBotTask 
{
    CBaseEntity@ m_pItem;

    CPickupItemTask ( RCBot@ bot, CBaseEntity@ item )
    {
        @m_pItem = item;
    } 

    void execute ( RCBot@ bot )
    {
        BotMessage("CPickupItemTask");

        if ( m_pItem.pev.effects & EF_NODRAW == EF_NODRAW )
        {
            BotMessage("EF_NODRAW");
            Complete();
        }

        if ( bot.distanceFrom(m_pItem) > 48 )
        {
            bot.setMove(m_pItem.pev.origin);

             BotMessage("bot.setMove(m_pItem.pev.origin);");
        }
        else
            Complete();
    }
}



final class CUseArmorCharger : RCBotTask
{
    CBaseEntity@ m_pCharger;

    CUseArmorCharger ( RCBot@ bot, CBaseEntity@ charger )
    {
        @m_pCharger = charger;
    } 

    void execute ( RCBot@ bot )
    {
        BotMessage("CUseArmorCharger");

        if ( m_pCharger.pev.frame == 0 )
        {
            Complete();
            BotMessage(" m_pCharger.pev.frame == 0");
        }
        if ( bot.m_pPlayer.pev.armorvalue >= 100 )
        {
            Complete();
            BotMessage(" bot.m_pPlayer.pev.armorvalue >= 100");
        }

        if ( bot.distanceFrom(m_pCharger) > 56 )
        {
            bot.setMove(m_pCharger.pev.origin);
            BotMessage("bot.setMove(m_pCharger.pev.origin)");
        }
        else
        {
            bot.setLookAt(m_pCharger.pev.origin);
            BotMessage("bot.PressButton(IN_USE)");

            if ( Math.RandomLong(0,100) < 99 )
            {
                bot.PressButton(IN_USE);
            }
        }
    }  
}

final class CUseHealthChargerTask : RCBotTask
{
    CBaseEntity@ m_pCharger;

    CUseHealthChargerTask ( RCBot@ bot, CBaseEntity@ charger )
    {
        @m_pCharger = charger;
    } 

    void execute ( RCBot@ bot )
    {
        if ( m_pCharger.pev.frame == 0 )
            Complete();
        if ( bot.m_pPlayer.pev.health >= bot.m_pPlayer.pev.max_health )
            Complete();

        if ( bot.distanceFrom(m_pCharger) > 56 )
            bot.setMove(m_pCharger.pev.origin);
        else
        {
            bot.setLookAt(m_pCharger.pev.origin);

            if ( Math.RandomLong(0,100) < 99 )
            {
                bot.PressButton(IN_USE);
            }
        }
    }  
}

final class CBotButtonTask : RCBotTask 
{
    int m_iButton;

    CBotButtonTask ( int button )
    {
        m_iButton = button;
    }

    void execute ( RCBot@ bot )
    {
        bot.PressButton(m_iButton);
        Complete();
    }
}

final class CFindPathTask : RCBotTask
{
    RCBotNavigator@ navigator;

    CFindPathTask ( RCBot@ bot, int wpt )
    {
        @navigator = RCBotNavigator(bot,wpt);
    }

    CFindPathTask ( RCBot@ bot, Vector origin )
    {
        @navigator = RCBotNavigator(bot,origin);
    }
/*
}
	const int NavigatorState_Complete = 0;
	const int NavigatorState_InProgress = 1;
	const int NavigatorState_Fail = 2;
*/
    void execute ( RCBot@ bot )
    {
        @bot.navigator = navigator;

        switch ( bot.navigator.run() )
        {
        case NavigatorState_Complete:
            // follow waypoint
            //BotMessage("NavigatorState_Complete");
        break;
        case NavigatorState_InProgress:
            // waiting...
           // BotMessage("NavigatorState_InProgress");
        break;
        case NavigatorState_Fail:
           // BotMessage("NavigatorState_Fail");
            Failed();
        break;
        case NavigatorState_ReachedGoal:

           /// BotMessage("NavigatorState_ReachedGoal");
            Complete();

            break;
        }

    }
}

class CFindPathSchedule : RCBotSchedule
{
    CFindPathSchedule ( RCBot@ bot, int iWpt )
    {
        addTask(CFindPathTask(bot,iWpt));
    }
}


class CBotTaskFindCoverSchedule : RCBotSchedule
{    
    CBotTaskFindCoverSchedule ( RCBot@ bot, CBaseEntity@ hide_from )
    {
        addTask(CBotTaskFindCoverTask(bot,hide_from));
        // reload when arrive at cover point
        addTask(CBotButtonTask(IN_RELOAD));
    }
    
}

class CBotTaskFindCoverTask : RCBotTask
{    
    RCBotCoverWaypointFinder@ finder;

    CBotTaskFindCoverTask ( RCBot@ bot, CBaseEntity@ hide_from )
    {
        @finder = RCBotCoverWaypointFinder(g_Waypoints.m_VisibilityTable,bot,hide_from);    

        if ( finder.state == NavigatorState_Fail )
        {
            BotMessage("FINDING COVER FAILED!!!");
            Failed();
        }
    }


     void execute ( RCBot@ bot )
     {
         if ( finder.execute() )
         {
             m_pContainingSchedule.addTask(CFindPathTask(bot,finder.m_iGoalWaypoint));
             BotMessage("FINDING COVER COMPLETE!!!");
             Complete();
         }
         else
            Failed();
     }
}


/// UTIL

abstract class CBotUtil
{
    float utility;
    float m_fNextDo;
    RCBot@ m_pBot;

    CBotUtil (  RCBot@ bot ) 
    { 
        utility = 0; 
        m_fNextDo = 0.0;   
        @m_pBot = bot;
    }

    void reset ()
    {
        m_fNextDo = 0.0;
    }

    bool canDo ()
    {
        return g_Engine.time > m_fNextDo;
    }

    void setNextDo ()
    {
        m_fNextDo = g_Engine.time + 30.0f;
    }

    RCBotSchedule@ execute ( RCBot@ bot )
    {
        return null;
    }

    float calculateUtility ( RCBot@ bot )
    {
        return 0;
    }    

    void setUtility ( float util )
    {
        utility = util;
    }
}

class CBotGetHealthUtil : CBotUtil
{
    CBotGetHealthUtil ( RCBot@ bot )
    {
        super(bot);
    }

    float calculateUtility ( RCBot@ bot )
    {
        float healthPercent = float(bot.m_pPlayer.pev.health) / bot.m_pPlayer.pev.max_health;
     
        return (1.0f - healthPercent);
    }

    RCBotSchedule@ execute ( RCBot@ bot )
    {
        int iWpt = g_Waypoints.getNearestFlaggedWaypoint(bot.m_pPlayer,W_FL_HEALTH);				

        if ( iWpt != -1 )
        {
            RCBotSchedule@ sched = CFindPathSchedule(bot,iWpt);

            sched.addTask(CFindHealthTask());

            return sched;
        }

        return null;
    }
}

class CBotGetAmmo : CBotUtil
{
    CBotGetAmmo ( RCBot@ bot )
    {
        super(bot);
    }
    
   float calculateUtility ( RCBot@ bot )
    {
        return 0.5;
    }

    RCBotSchedule@ execute ( RCBot@ bot )
    {
        int iWpt = g_Waypoints.getNearestFlaggedWaypoint(bot.m_pPlayer,W_FL_AMMO);				

        if ( iWpt != -1 )
        {
            RCBotSchedule@ sched = CFindPathSchedule(bot,iWpt);
            sched.addTask(CFindAmmoWeaponTask());
            return sched;
        }

        return null;
    }    
}

class CBotGetArmorUtil : CBotUtil
{
    CBotGetArmorUtil ( RCBot@ bot )
    {
        super(bot);
    }
    
   float calculateUtility ( RCBot@ bot )
    {
        float healthPercent = float(bot.m_pPlayer.pev.armorvalue) / 100;

        return (1.0f - healthPercent);
    }

    RCBotSchedule@ execute ( RCBot@ bot )
    {
        int iWpt = g_Waypoints.getNearestFlaggedWaypoint(bot.m_pPlayer,W_FL_ARMOR);				

        if ( iWpt != -1 )
        {
             RCBotSchedule@ sched = CFindPathSchedule(bot,iWpt);

             sched.addTask(CFindArmorTask());   

             return sched;
        }
        return null;
    }    
}

class CBotRoamUtil : CBotUtil
{
    CBotRoamUtil( RCBot@ bot )
    {
        super(bot);
    }

    float calculateUtility ( RCBot@ bot )
    {
        return (0.1);
    }

    void setNextDo ()
    {
        m_fNextDo = g_Engine.time + 1.0f;
    }    

    RCBotSchedule@ execute ( RCBot@ bot )
    {
        int iRandomGoal = g_Waypoints.getRandomFlaggedWaypoint(W_FL_ENDLEVEL);

        if ( iRandomGoal == -1 )
            iRandomGoal = g_Waypoints.getRandomFlaggedWaypoint(W_FL_IMPORTANT);    

        if ( iRandomGoal != -1 )
        {
            return CFindPathSchedule(bot,iRandomGoal);
        }

        return null;
    }
}

class CBotUtilities 
{
    array <CBotUtil@>  m_Utils;

    CBotUtilities ( RCBot@ bot )
    {
            m_Utils.insertLast(CBotGetHealthUtil(bot));
            m_Utils.insertLast(CBotGetArmorUtil(bot));
            m_Utils.insertLast(CBotRoamUtil(bot));
            m_Utils.insertLast(CBotGetAmmo(bot));
    }

    void reset ()
    {
        for ( uint i = 0; i < m_Utils.length(); i ++ )
        {
             m_Utils[i].reset();            
        }
    }

    RCBotSchedule@  execute ( RCBot@ bot )
    {
        array <CBotUtil@>  UtilsCanDo;

        for ( uint i = 0; i < m_Utils.length(); i ++ )
        {
            if ( m_Utils[i].canDo() )
            {
                   
                m_Utils[i].setUtility(m_Utils[i].calculateUtility(bot));
                BotMessage("Utility = " + m_Utils[i].utility);
                UtilsCanDo.insertLast(m_Utils[i]);
            }
        }

        if ( UtilsCanDo.length() > 0 )
        {
            UtilsCanDo.sort(function(a,b) { return a.utility > b.utility; });

            for ( uint i = 0; i < UtilsCanDo.length(); i ++ )
            {
                RCBotSchedule@ sched = UtilsCanDo[i].execute(bot);

                if ( sched !is null )
                {
                    
                    UtilsCanDo[i].setNextDo();
                    return sched;
                }
            }
        }

        return null;
    }
}