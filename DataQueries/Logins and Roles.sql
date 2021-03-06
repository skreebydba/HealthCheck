/* 
Name: Logins and Roles
Purpose: List server-level logins, and role members.  
Date created: 2016/02/08  
Permissions needed to run: ALTER ANY DATABASE or VIEW ANY DATABASE 
Notes: 

Modification date:  
Modified by: 
Modification:  
*/

INSERT INTO Concurrency.hlthchk.ServerPrincipals
(PrincipalName
,[SID]
,TypeDesc
,IsDisabled
,DefaultDatabaseName)
select name, sid, type_desc, is_disabled, ISNULL(default_database_name, 'No Default')
from sys.server_principals ;

INSERT INTO Concurrency.hlthchk.Logins
(RolePrincipalId
,RoleName
,MemberPrincipalId
,MemberName)
SELECT SRM.role_principal_id, 
	role.name AS RoleName, 
	SRM.member_principal_id, 
	member.name AS MemberName
FROM sys.server_role_members SRM
JOIN sys.server_principals AS role 
    ON SRM.role_principal_id = role.principal_id
JOIN sys.server_principals AS member
    ON SRM.member_principal_id = member.principal_id;