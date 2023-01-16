Write-Host ""
Write-Host "#############################################"
Write-Host "Welcome to My File Integrity Monitor!!!"
Write-Host " "
Write-Host "Would you like to:"
Write-Host " "
Write-Host "(E) Use Existing Baseline And Check Live Status?"Write-Host "(N) Use New Baseline?"
Write-Host "(L) Files Tampered State ?"
Write-Host " "

$UserInput= Read-Host -Prompt "Please Enter 'E', 'N' or 'T'" 
Write-Host " "

Write-Host "User Entered" ($UserInput)
Write-Host " "


       

if ($UserInput -eq "N".ToUpper()) {
       
        #Calculate Hash from files, and store in Baseline.txt
        
       
        Erase-Baseline-If-Already-Exists  #Calling Function to Erase Baseline

        BaseLine_Update    # Calling Function to update Baseline

        Write-Host "Calculating Hashes!!!!!" -ForegroundColor Green
        Write-Host "Congrats!!! New BaseLine Has Been Created" -ForegroundColor Green
        Write-Host " "

}

if ($UserInput -eq "E".ToUpper()) {

        #load file-hash from baseline.txt and store them in a dictionary
        #Begin Monitoring files with saved Baseline

                Load_FileHashDictionary   #Calling Function to Load contents in FileHashDictionary

        #Begin continuously Monitoring files with saved Baseline

                While($true){Continuous_Monitoring}
}


if ($UserInput -eq "T".ToUpper()){

            Load_FileHashDictionary
            Continuous_Monitoring
}




Function Calculate_File_Hash($filepath){
    $filehash = Get-FileHash -PATH $filepath -Algorithm SHA512
    return $filehash
}



Function Erase-Baseline-If-Already-Exists() {

$BaseLineExists = Test-Path -Path .\Baseline.txt

if($BaseLineExists){
Remove-Item -Path .\Baseline.txt
    }
}





Function BaseLine_Update(){

 $files = Get-ChildItem -Path .\Desktop\ToBeChecked

        foreach($f in $files){
               $hash = Calculate_File_Hash $f.FullName 
               
               "$($hash.Path)|$($hash.Hash)" | Out-File -FilePath .\Baseline.txt -Append

               $Global:TotalFileCount = $files.Count
        }

        Write-Host "BaseLine_Update Method Call Succesful"
            
    }



Function Load_FileHashDictionary(){

        $Global:FileHashDictionary = @{}

        Write-Host "Reading existing Baseline.txt, start monitoring files." -ForegroundColor green
        Write-Host " "

        $FilePathsAndHashes = Get-Content -Path .\Baseline.txt

        foreach($f in $FilePathsAndHashes){ 
        $FileHashDictionary.add($f.Split("|")[0],$f.Split("|")[1])
        }

}



Function Continuous_Monitoring(){

          Start-Sleep -Seconds 1

          $files = Get-ChildItem -Path .\Desktop\ToBeChecked
                
          foreach($f in $files){

              $hash = Calculate_File_Hash $f.FullName

              $MatchingCondition = $FileHashDictionary[$hash.Path]

              Switch($MatchingCondition){

                      ($null){
                           Write-Host "$($hash.Path) has been created as new file" -ForegroundColor DarkMagenta
                           Write-Host " "     
                         }

                      ($hash.Hash){
                           Write-Host "File $($hash.Path) is safe and there is no changes" -Foregroundcolor green
                           Write-Host " "              
                         }

                            
                       Default{
                           Write-Host "$($hash.Path) has been Modified!!!"  -ForegroundColor Yellow -BackgroundColor Black    
                           Write-Host " "
                           
                           
                        }
                }
       }


       foreach($key in $FileHashDictionary.Keys){
                              $DeleteCondition = !(Test-Path -Path $key)
                              if($DeleteCondition){ 
                                   Write-Host "$($key) has been deleted" -ForegroundColor DarkRed -BackgroundColor Black
                                   Write-Host " "
                              }
                    }
        }