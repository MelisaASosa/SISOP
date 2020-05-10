Param (
    [Parameter(Position = 1, Mandatory = $false)]
    [String] $pathsalida = ".\procesos.txt ",
    [int] $cantidad = 3
)

$existe = Test-Path $pathsalida

if ($existe -eq $true) {
    $listaproceso = Get-Process
    foreach ($proceso in $listaproceso) {
        $proceso | Format-List -Property Id,Name >> $pathsalida
    }
    for ($i = 0; $i -lt $cantidad ; $i++) {
        Write-Host $listaproceso[$i].Name - $listaproceso[$i].Id
    }
} else {
    Write-Host "El path no existe"
}

<#
    1. El script escribe en un archivo que recibe como parámetro ($pathsalida) los procesos del sistema, detallando id y nombre.
       Después muestra por pantalla la cantidad de procesos que recibe como parámetro ($cantidad).
    2. Se podría validar que el parámetro $pathsalida, además de existir, sea un archivo.
    3. Si se ejecuta el script sin ningun parámetro se le van a asignar los valores por defecto que son:
        Para el parámetro pathsalida -> ".\procesos.txt"
        Para el parámetro cantidad -> 3
#>