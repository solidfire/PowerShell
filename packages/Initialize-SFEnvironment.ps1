<#
# Copyright © 2014-2016 NetApp, Inc. All Rights Reserved.
#
# CONFIDENTIALITY NOTICE: THIS SOFTWARE CONTAINS CONFIDENTIAL INFORMATION OF
# NETAPP, INC. USE, DISCLOSURE OR REPRODUCTION IS PROHIBITED WITHOUT THE PRIOR
# EXPRESS WRITTEN PERMISSION OF NETAPP, INC.
#>

# Launch text
import-module SolidFire

$version = (Get-Module SolidFire).Version[0]

$host.ui.RawUI.WindowTitle ="SolidFire PowerShell Tools $version"

write-host "                                                                           " 
Write-Host "             777777                                                        " 
Write-Host "            777777777                                                      " 
Write-Host "             7777777777                                                    " 
Write-Host "               7777777777                                                  " 
Write-Host "                77777777777                                                " 
Write-Host "                  7777777777                                               " 
Write-Host "                   77777777777                                             " 
Write-Host "                     77777777777                                           " 
Write-Host "                       77777777777                                         " 
Write-Host "                        77777777777                                        " 
Write-Host "                          7777777777                      77               " 
Write-Host "                           777777777                     7777              " 
Write-Host "                         7777777777                       77               " 
Write-Host "                       7777777777                         ==               " 
Write-Host "                      7777777777                          ==               " 
Write-Host "                    7777777777          77IIIIIIIIIIIIIIIIII777            " 
Write-Host "                  77777777777         =7                       7=          " 
Write-Host "                 7777777777           7                         7          " 
Write-Host "               7777777777            =7                         7=         " 
Write-Host "             77777777777             =7                         7=         " 
Write-Host "           77777777777              =77   7777777777777777777   77=        " 
Write-Host "          7777777777               7777  777777777777777777777  7777       " 
Write-Host "           7777777                 7777   7777777777777777777   7777       " 
Write-Host "             777                    =77                         77=        " 
Write-Host "                                     =7                         7=         " 
Write-Host "                                      7                         7          " 
Write-Host "                                      7                         7          " 
Write-Host "                                      7=                       =7          " 
Write-Host "                                       77=                   =77           " 
Write-Host "                                         =7777777777777777777=             " 
Write-Host "                                                                           " 
Write-Host "                                          ====IIIIIIIIII=====              " 
Write-Host "                                    =77777=                 =77777=        " 
Write-Host "                                =777=                             =777=    " 
Write-Host "                            =777=                                     =777=" 
Write-Host "                                                                           " 
write-host "                   Welcome to SolidFire PowerShell Tools" -foregroundcolor blue 
Write-Host "                           Version $version             " -foregroundcolor blue 
Write-Host ""
write-host "       To log into a SolidFire Cluster or Node:       " -NoNewLine
write-host "Connect-SFCluster" -foregroundcolor blue
write-host "       To list available commands, type:              " -NoNewLine
write-host "Get-SFCommand" -foregroundcolor blue
write-host "       To get help for SolidFire commands use:        " -NoNewline
write-host "Get-Help <SolidFire CmdLet>" -foregroundcolor blue
write-host ""
write-host "           Copyright © 2015 - 2017 NetApp, Inc. All Rights Reserved."

function global:Get-SFCommand([string] $Name = "*") {
  get-command -Module SolidFire -Name $Name
}
