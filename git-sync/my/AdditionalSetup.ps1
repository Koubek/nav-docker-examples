# Invoke default behavior
. (Join-Path $runPath $MyInvocation.MyCommand.Name)

if (!$restartingInstance) {
    Install-Chocolatey
    Install-Git
    
    Register-NavChangeTracker
}

Export-ClientFolder