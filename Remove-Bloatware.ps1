function Remove-Bloatware {
    # List Bloatware using DISM
    # DISM /Online /Get-ProvisionedAppxPackages | select-string PackageName
    # Need to use Get-AppxPackage and Remove-AppxPackage

    DISM /Online /Remove-ProvisionedAppxPackage /PackageName:WildTangentGames.63435CFB65F55_2.0.46.0_neutral_~_qt5r5pa5dyg8m | Out-Null
    DISM /Online /Remove-ProvisionedAppxPackage /PackageName:eBay_1.0.1606.2210_x64__96rgg7pjt343r | Out-Null
    DISM /Online /Remove-ProvisionedAppxPackage /PackageName:Amazon.com.Amazon_2018.519.2811.0_neutral_~_343d40qqvtj1t | Out-Null
    DISM /Online /Remove-ProvisionedAppxPackage /PackageName:4AE8B7C2.Booking.comPartnerApp_1.1.2.1000_neutral_~_6wqyppa9wfhnr | Out-Null
    DISM /Online /Remove-ProvisionedAppxPackage /PackageName:7EE7776C.LinkedInforWindows_2.1.7098.0_neutral_~_w1wdnht996qgy | Out-Null
    DISM /Online /Remove-ProvisionedAppxPackage /PackageName:Evernote.Evernote_2018.814.2134.0_neutral_~_q4d96b2w5wcc2 | Out-Null
    DISM /Online /Remove-ProvisionedAppxPackage /PackageName:26720RandomSaladGamesLLC.SimpleMahjong_5.2.32.0_neutral_~_kx24dqmazqk8j | Out-Null
    DISM /Online /Remove-ProvisionedAppxPackage /PackageName:26720RandomSaladGamesLLC.SimpleSolitaire_6.11.32.0_neutral_~_kx24dqmazqk8j | Out-Null
    DISM /Online /Remove-ProvisionedAppxPackage /PackageName:26720RandomSaladGamesLLC.Spades_5.2.24.0_neutral_~_kx24dqmazqk8j | Out-Null
    DISM /Online /Remove-ProvisionedAppxPackage /PackageName:4DF9E0F8.Netflix_6.76.314.0_x64__mcm4njqhnhss8 | Out-Null
}