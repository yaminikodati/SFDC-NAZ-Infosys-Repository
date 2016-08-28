public with sharing class apppanel{ 
public List<AppMenuItem> Records {get; set;} 
public apppanel(){ 
Records = 
[select Name, Id, Label, LogoUrl, IconUrl, StartUrl from AppMenuItem]; 
} 
}