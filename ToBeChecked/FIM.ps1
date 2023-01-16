
Function Calculate_File_Hash($filepath){

    $filehash = Get-FileHash $filepath -Algorithm SHA512
    return $filehash
}

Function Erase-Baseline-If-Already-Exists(){

$BaseLineExists = Test-Path -Path .\Baseline.txt

if($BaseLineExists){
Remove-Item -Path .\Baseline.txt
    }
}




Write-Host ""
Write-Host "#############################################"
Write-Host "Welcome to My File Integrity Monitor!!!"
Write-Host "Would you like to:"
Write-Host "(E) Use Existing Baseline?"Write-Host "(N) Use New Baseline?"

$UserInput= Read-Host -Prompt "Please Enter 'E' or 'N'" 

Write-Host "User Entered" ($UserInput)


       

if ($UserInput -eq "N".ToUpper()) {
       
        #Calculate Hash from files, and store in Baseline.txt
        Write-Host "Calculating Hashes, and Making New Baseline.txt" -ForegroundColor DarkMagenta
       

        Erase-Baseline-If-Already-Exists

        $files = Get-ChildItem -Path .\ToBeChecked

        foreach($f in $files){
               $hash = Calculate_File_Hash $f.FullName "$($hash.Path)|$($hash.Hash)" | Out-File -FilePath .\Baseline.txt -Append 
        }


}

elseif ($UserInput -eq "E".ToUpper()) {

        #load file-hash from baseline.txt and store them in a dictionary
        #Begin Monitoring files with saved Baseline

        $FileHashDictionary = @{}

        Write-Host "Reading existing Baseline.txt, start monitoring files." -ForegroundColor green

        $FilePathsAndHashes = Get-Content -Path .\Baseline.txt

        foreach($f in $FilePathsAndHashes){ 
        $FileHashDictionary.add($f.Split("|")[0],$f.Split("|")[1])
        }

        #Begin continuously Monitoring files with saved Baselines

        While($true){
                Start-Sleep -Seconds 1

                $files = Get-ChildItem -Path .\ToBeChecked
                
                foreach($f in $files){

                $hash = Calculate_File_Hash $f.FullName

                if($FileHashDictionary[$hash.Path] -eq $null){
                                    Write-Host "$($hash.Path) has been created as new file" -ForegroundColor DarkGreen
                    }

                 else{
                    
                    if($FileHashDictionary[$hash.Path] -eq ($hash.Hash)){
                                #Write-Host "Files are safe and there is no changes" -Foregroundcolor DarkMagenta
                 
                    }


                    else{
                            Write-Host "$($hash.Path) has been changed!!!"  -ForegroundColor DarkRed                  
                    }

                }
        
        }

      <#  foreach ($key in $FileHashDictionary.Keys){

                        $BaselineStillExists = Test-Path -Path $key

                        if(-Not $BaselineStillExists){
                            Write-Host "$($key) has been deleted" -ForegroundColor DarkRed -BackgroundColor Gray

                            }
            }   #>
    }

}


