#!/usr/bin/env bash
# WARNING: All checks are case sensitive

red='\033[0;31m'
no_color='\033[0m'
yellow='\033[0;33m'
release_bypass=false
LC_ALL=C
name_policy="https://github-lvs.corpzone.internalzone.com/mcafee/FedeTest/NAMING_CONVENTION.md"

branch_name_test (){ 
    if [[ $branch == "master" ]]
    then
        exit 0
    elif [[ $branch =~ ^rel-[0-9][0-9.]*[0-9]$ ]] # Release branch
    then
        if [ "$release_bypass" = true ]
        then 
            exit 0
        else
            printf "${red}Release branch creation is restricted, please contact Olle, Juan or Fuente, Pablo.${no_color}"
            exit 1
        fi
    elif [[ $branch =~ ^\[SEC-[0-9]*[0-9]\]-[A-Z]+$ ]] # Jira ID branch
    then
        exit 0
    else
        printf " The branch name does not match the configured name rules. The branch is named $branch"
        wrong_branch_name
    fi
}

wrong_branch_name (){
    printf "\n${red}The branch name rules can be found here: ${yellow}$name_policy${red}. You will need to change the name of your branch.${no_color}\n${red}Should you need to bypass this test, you can contact Lenarduzzi, Federico${no_color}\n${red}Aborting push${no_color}" 
    exit 1
}

while read oldrev newrev refname
do
    branch=${refname:11}
    if [[ $oldrev == "0000000000000000000000000000000000000000" ]] # If the old ref has this value it does not exist and a new branch is being created
    then 
        for ((n=0;n<$GIT_PUSH_OPTION_COUNT;n++)) # Iterate over all push options (-o "option") to see if one has no_check
        do
            push_option=GIT_PUSH_OPTION_${n}
            if [[ ${!push_option} == "no_check" ]] # If the option has "no_check", exit and let push continue
            then
                printf "bypassing name check"
                exit 0
            elif [[ ${!push_option} == "release_bypass" ]] # If the option has "release_bypass", allow only release branch bypassing
            then
                printf "bypassing release restrictions"
                release_bypass=true
            fi
        done
        branch_name_test # If none of the options have the "no_check" flag, check branch name
    else
        exit 0
    fi
    exit 0
done