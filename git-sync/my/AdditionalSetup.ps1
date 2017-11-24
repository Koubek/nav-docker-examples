# Invoke default behavior
. (Join-Path $runPath $MyInvocation.MyCommand.Name)

if (!$restartingInstance) {
    Register-NavChangeTracker
}

Export-ClientFolder