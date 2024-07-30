-- RemoveAccpacCustomComponents

-- This file removes the Accpac Custom Components
-- based upon the known component names 

exec usp_UninstallAccpacComponent 'PRCompany'
exec usp_UninstallAccpacComponent 'PRGeneral'
exec usp_UninstallAccpacComponent 'PRLookups'
exec usp_UninstallAccpacComponent 'PRPACA'
exec usp_UninstallAccpacComponent 'PRPerson'
exec usp_UninstallAccpacComponent 'PRRating'
exec usp_UninstallAccpacComponent 'PRTradeReport'
exec usp_UninstallAccpacComponent 'PRTransaction'


