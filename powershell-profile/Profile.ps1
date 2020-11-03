function tsarev_git_update_master
{
    $hasEditsToTrackedFiles  = !([string]::IsNullOrEmpty($(git status --porcelain --untracked-files=no)))
    if ($hasEditsToTrackedFiles)
    {
        git stash
    }

    if (-not $?) {throw "!"}
    git checkout master
    if (-not $?) {throw "!"}
    git pull
    if (-not $?) {throw "!"}

    if ($hasEditsToTrackedFiles)
    {
        git stash pop
    }
}

set-item -path alias:"git-update-master" -value tsarev_git_update_master

function tsarev_git_new_branch {
    Param(
      [Parameter(Mandatory = $true, Position = 0)]
      [String]
      $branch_name
    )

    tsarev_git_update_master

    git checkout -B $branch_name

  }

  set-item -path alias:"git-new-task" -value tsarev_git_new_branch

function tsarev_go_to_repo {
    Param(
        [Parameter(Mandatory = $true, Position = 0)]
        [String]
        $repo_name
      )

    Set-Location "C:\Users\leonid.tsarev\Source\Repos\$repo_name"
}

set-item -path alias:"set-repo" -value tsarev_go_to_repo

Register-ArgumentCompleter -Native -CommandName dotnet -ScriptBlock {
    param($commandName, $wordToComplete, $cursorPosition)
        dotnet complete --position $cursorPosition "$wordToComplete" | ForEach-Object {
           [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
}

Register-ArgumentCompleter -Native -CommandName winget -ScriptBlock {
    param($wordToComplete, $commandAst, $cursorPosition)
        [Console]::InputEncoding = [Console]::OutputEncoding = $OutputEncoding = [System.Text.Utf8Encoding]::new()
        $Local:word = $wordToComplete.Replace('"', '""')
        $Local:ast = $commandAst.ToString().Replace('"', '""')
        winget complete --word="$Local:word" --commandline "$Local:ast" --position $cursorPosition | ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
}

Import-Module posh-git
