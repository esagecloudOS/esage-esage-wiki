#! /bin/sh
# Convert Privileges in java.properties and Roles in SQL Table and Extra Comments to Confluence Wiki Format
# Based on http://shrubbery.mynetgear.net/c/display/W/Reading+Java-style+Properties+Files+with+Shell#ReadingJava-stylePropertiesFileswithShell-Method2reloaded-UseAWK
# Read concatenated privileges, roles and extras in properties file $1 and write to properties output $2
# Ignore GUI LABELS 
# Privileges file has this general format and is processed as follows to give output:
#
# LABEL_HOME=Home
# ENTERPRISE_ENUMERATE=List all enterprises
# ENTERPRISE_ENUMERATE_DESC=This privilege allows a user to view the list of enterprises and to view statistics for those enterprises 
#
# h4. User Privileges
# || GUI Label            || Application Tag      || Privilege                          ||
# |  List all enterprises  | ENTERPRISE_ENUMERATE  | This privilege allows a user to...  | 
#
# Save the ENTERPRISE_ENUMERATE and use it as a key to the Roles database output, for example
#
# | ENTERPRISE_ENUMERATE                 | CLOUD_ADMIN      | 
#
# Also use it as a key to add extra text to the privilege description
#
# EXTRA_TEXT | USERS_MANAGE_ENTERPRISE_BRANDING | *This privilege is only visible after branding is enabled. By default it is not assigned to a role.* 
#
# Print all of this together separated by | for wiki format of privileges
#
# | List all enterprises | ENTERPRISE_ENUMERATE | This privilege allows a user to view the list of enterprises and to view statistics for those enterprises | X |  |  |
#
## replace {} with ""
## replace \n with "- "
## replace \: with :
## replace [] with (),
# 
cat $1 | gawk --posix  'BEGIN { FS="=|\\|"; } 
{
if ($0 ~ /^(LABEL_ALL)|(LABEL_MORE_INFO)|(LABEL_ADDED)|(LABEL_DELETED)|(LABEL_FOR_ROLE)|(BUTTON)/)
   { next; }
if ($0 ~ /^(EXTRA_TEXT)/)
{
   ind = $2;
   gsub(/ */,"",ind);
   extras[ind] = $3;
}
if ($0 ~ /^(LABEL)/)
{
   output_row[NR] = "h4. " $2 " Privileges \n || GUI Label   {color:#efefef}______________________{color} || Application Tag \\\\  {color:#efefef}_______________________________________________{color} " \
" || Privilege  {color:#efefef}__________________________________________{color}|| Cloud Admin || Ent Admin || Ent User ||" ;
} 
else
{
   if (NF == 2)
   {
      if ($1 !~ /(DESC)$/)
      {
         ind = $1;
         app_tag[ind] = $1;
         gui_label[ind] = $2;
         output_row[NR] = "GUILABEL";
      }
      else
     {
         app_tag_sub = $1;
         gsub(/_DESC/,"",app_tag_sub);
         ind = app_tag_sub;         
         privilege[ind] = $2;
         output_row[NR] = "| " gui_label[ind] " | " app_tag[ind] " | " privilege[ind] " " ;
         output_content [ind] = output_row[NR];
         output_row_content [NR] = ind;
      }  
   }
  else
  {
     if ($2)
     {
     ind = $2;
     gsub(/ */,"",ind);
     if ($3 ~ "CLOUD_ADMIN")
     {
        cloud_adm[ind] = "X";
     }
     if ($3 ~ "ENTERPRISE_ADMIN")
     {
        ent_admin[ind] = "X";
     }
     if ($3 ~ "USER")
     {
        ent_user[ind] = "X";
     }
     output_roles[ind] =  "| " cloud_adm[ind] " | "  ent_admin[ind] " | " ent_user[ind] " |" ;
     }
  }  
}
}
END {     
# output_roles[USERS_MANAGE_ENTERPRISE_BRANDING] = " | | | |";
for (s=1; s<=NR; s++) 
   {
      if (output_row[s] !~ "GUILABEL") 
      {
         if (output_row[s] ~ /^h4/)
           { print output_row[s] }
         else
           {
             j = output_row_content[s]; 
             m = extras[j]
             k = output_content[j];
             l = output_roles[j];
             if (j)
               {print k m l; } 
           }
     }
}
} ' >$2
