﻿#SISTEMAS OPERATIVOS - TRABAJO PRACTICO NRO 2 - PRIMER ENTREGA - EJERCICIO 2

#INTEGRANTES:
#CICARONE, FLORENCIA - 40712842
#MUÑOZ, ROCIO CELESTE - 39788890
#SOSA, MELISA AGUSTINA - 40464205

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
.\procesarLogs.ps1 -Path /logs/
#>

Param(
    [Parameter(Mandatory=$true)]
    $directorio
)

## FUNCIONES ##
function mostrarResultadosDiarios {
    Param(
        [DateTime] $dia
    )

    $acumuladoTiempoDiario = ($acumuladoTiempoPorUsuarioPorDia.Values | Measure-Object -Sum).Sum
    $cantidadDiaria = ($cantidadLlamadasPorUsuarioPorDia.Values | Measure-Object -Sum).Sum

    $promedio = [timespan]::fromseconds($acumuladoTiempoDiario / $cantidadDiaria)
    
    Write-Host "-------------  " $dia.ToShortDateString() "  --------------"
    Write-Host "El promedio de tiempo de las llamadas es: $promedio `n"

    foreach ($cantidadUsuario in $cantidadLlamadasPorUsuarioPorDia.GetEnumerator()) {
        $usuario = $cantidadUsuario.Name
        
        $cantidad = $cantidadUsuario.Value
        $acumulado = @($acumuladoTiempoPorUsuarioPorDia.GetEnumerator() | Where-Object {$_.Name -eq $usuario}).Value
        
        $promedioUsuario = [timespan]::fromseconds($acumulado / $cantidad)

        Write-Host "La cantidad de llamadas de $usuario en el día es de: $cantidad"
		Write-Host "El promedio de tiempo de las llamadas de $usuario en el día es de: $promedioUsuario `n"
    }

    $cantidadLlamadasMenorPromedio = 0

    foreach($tiempo in $tiemposLlamadasPorDia.GetEnumerator()) {
        if($tiempo.Value -lt $promedio) {
            $cantidadLlamadasMenorPromedio++
        }
    }

    Write-Host "La cantidad de llamadas que no superan la media de tiempo ($promedio) es: $cantidadLlamadasMenorPromedio `n`n"
}

function mostrarResultadosSemanales {
    Param(
        $infoLog
    )

    $cantidadLlamadasPorUsuarioPorSemana = $cantidadLlamadasPorUsuarioPorSemana.GetEnumerator() | Sort-Object -Property Value -Descending

    Write-Host "Los 3 usuarios con más llamadas en la semana son: "
    Write-Host "1." $cantidadLlamadasPorUsuarioPorSemana[0].Name ":" $cantidadLlamadasPorUsuarioPorSemana[0].Value "llamadas"
    Write-Host "1." $cantidadLlamadasPorUsuarioPorSemana[1].Name ":" $cantidadLlamadasPorUsuarioPorSemana[1].Value "llamadas"
    Write-Host "1." $cantidadLlamadasPorUsuarioPorSemana[2].Name ":" $cantidadLlamadasPorUsuarioPorSemana[2].Value "llamadas`n"

    #Calculo promedio semanal
    
    $tiempoTotalSemanal = ($acumuladoTiempoPorUsuarioPorSemana.Values | Measure-Object -Sum).Sum
    $cantidadTotalSemanal = ($cantidadLlamadasPorUsuarioPorSemana.Value | Measure-Object -Sum).Sum

    $promedioSemanal = [timespan]::fromseconds($tiempoTotalSemanal / $cantidadTotalSemanal)

    $cantidadDebajoMediaPorUsuario = @{}

    for($i = 0; $i -lt $infoLog.Count; $i++) {
        $usuario = $infoLog[$i].Usuario

        if($horariosInicioPorUsuario.$usuario -ne $null) {
            $tiempoLlamada = [DateTime]$infoLog[$i].Hora - [DateTime]$horariosInicioPorUsuario.$usuario
            $horariosInicioPorUsuario.$usuario = $null

            if($tiempoLlamada -lt $promedioSemanal) {
                $cantidadDebajoMediaPorUsuario.$usuario++
            }
        } else {
            $horariosInicioPorUsuario.$usuario = $infoLog[$i].Hora
        }
    }

    $cantidadDebajoMediaPorUsuario = $cantidadDebajoMediaPorUsuario.GetEnumerator() | Sort-Object -Property Value -Descending

    Write-Host "El usuario con más llamadas por debajo de la media semanal es: " $cantidadDebajoMediaPorUsuario[0].Name "(" $cantidadDebajoMediaPorUsuario[0].Value "llamadas )"

}
## END FUNCIONES ##

## MAIN ##

#Valido existencia de directorio
$Existe = Test-Path $directorio

if(!$Existe) {
    Write-Error "El directorio no existe"
    Exit
}

#Recorro el directorio de logs para procesar todos los logs existentes.
$semana = 1
foreach($logFile in Get-ChildItem $directorio) {

    $infoLog = Import-Csv -Path $logFile -Header 'Fecha', 'Hora', 'Guion', 'Usuario' -Delimiter " "
    $infoLog =  $infoLog | Select-Object -Property Fecha, Hora, Usuario | Sort-Object Fecha, Hora

    Write-Host "***LLAMADAS A PROCESAR***"
    $infoLog | Format-List

    $diaEnProceso = [DateTime]$infoLog[0].Fecha

    $cantidadLlamadasPorUsuarioPorDia = @{}
    $cantidadLlamadasPorUsuarioPorSemana = @{}
    $horariosInicioPorUsuario = @{}
    $acumuladoTiempoPorUsuarioPorDia = @{}
    $acumuladoTiempoPorUsuarioPorSemana = @{}
    $tiemposLlamadasPorDia = @{}

    $cont = 0

    Write-Host "*************  RESULTADOS SEMANA $semana  ************* `n"

    for($i = 0; $i -lt $infoLog.Count; $i++) {
        $diaRegistro = [DateTime]$infoLog[$i].Fecha
        $usuario = $infoLog[$i].Usuario

        if($diaEnProceso -ne $diaRegistro) {
            mostrarResultadosDiarios $diaEnProceso $cantidadLlamadasDiarias
            $cont=0
		    $cantidadLlamadasPorUsuarioPorDia = @{}
            $acumuladoTiempoPorUsuarioPorDia = @{}
        }
        
        if($horariosInicioPorUsuario.$usuario -ne $null) {
            $tiempoLlamada = [DateTime]$infoLog[$i].Hora - [DateTime]$horariosInicioPorUsuario.$usuario

            $acumuladoTiempoPorUsuarioPorDia.$usuario = $acumuladoTiempoPorUsuarioPorDia.$usuario + $tiempoLlamada.TotalSeconds
            $acumuladoTiempoPorUsuarioPorSemana.$usuario = $acumuladoTiempoPorUsuarioPorSemana.$usuario + $tiempoLlamada.TotalSeconds
            $tiemposLlamadasPorDia.$cont = $tiempoLlamada

            $cont++

            $horariosInicioPorUsuario.$usuario = $null
        } else {
            $cantidadLlamadasPorUsuarioPorDia.$usuario++
            $cantidadLlamadasPorUsuarioPorSemana.$usuario++
            $horariosInicioPorUsuario.$usuario = $infoLog[$i].Hora
        }

        $diaEnProceso = [DateTime]$infoLog[$i].Fecha
    }

    mostrarResultadosDiarios $diaEnProceso $cantidadLlamadasDiarias

    mostrarResultadosSemanales $infoLog

    Write-Host "*************  FIN RESULTADOS SEMANA $semana  ************* `n"

    $semana++
}
## FIN MAIN ##