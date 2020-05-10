<#
.SYNOPSIS
Procesamiento de logs semanales

.DESCRIPTION
Este script recorre el directorio de logs semanales y procesa los de cada semana mostrando los siguientes resultados:
▪ Promedio de tiempo de las llamadas realizadas por día.
▪ Promedio de tiempo y cantidad por usuario por día.
▪ Los 3 usuarios con más llamadas en la semana.
▪ Cuántas llamadas no superan la media de tiempo por día y el usuario que tiene más llamadas por debajo de la media en la semana.

.PARAMETER Path
Directorio en el que se encuentran los archivos de logs

.EXAMPLE
procesarLogs.ps1 -Path /logs/
#>

class Log {

    [String]$username;
    [datetime]$fecha;
    [datetime]$hora;
   
}

$lines = Get-Content -Path $args[0]

for($i=0; $i -le $lines.Length; $i++) {
    $log = Get-Content -Path $lines -Delimiter " "

    Write-Host $log[0] `n
    Write-Host $log[1] `n
    Write-Host $log[2] `n
    Write-Host $log[3] `n
    break
}
