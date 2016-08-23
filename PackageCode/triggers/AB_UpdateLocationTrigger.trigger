trigger AB_UpdateLocationTrigger on Account (before insert,before update) 
{
    if(Trigger.isBefore && (Trigger.isInsert ||Trigger.isUpdate))
    {
        if(Trigger.isUpdate)
        {
            for(Account a:Trigger.new)
            {
              if(a.BillingLatitude != Trigger.oldMap.get(a.id).BillingLatitude || a.BillingLongitude != Trigger.oldMap.get(a.id).BillingLongitude)
              {
                  if (a.BillingLatitude != null)
                  {
                    a.Location__Latitude__s = a.BillingLatitude ;
                    a.Location__Longitude__s =a.BillingLongitude;
                  }
               }
            }
        }
        if(Trigger.isUpdate)
        {
            for(Account a:Trigger.new)
            {
                if (a.BillingLatitude != null)
                {
                    a.Location__Latitude__s = a.BillingLatitude ;
                    a.Location__Longitude__s =a.BillingLongitude;
                }
            }
        }
    }
}