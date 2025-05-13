####################################################################################
##  File:  Install-AzureCosmosDbEmulator.ps1
##  Desc:  Install Azure CosmosDb Emulator
####################################################################################

Install-Binary -Type MSI `
    -Url "https://aka.ms/cosmosdb-emulator" `
    -ExpectedSHA256Sum "C380461A8959C125D5E7062C130F6F96FF94E7065497C1C20EDF86A19CF1BDE9"

Invoke-PesterTests -TestFile "Tools" -TestName "Azure Cosmos DB Emulator"
