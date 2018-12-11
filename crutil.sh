# Remove Unnecessary Certificates

delete_certificates() {
    cert_list=$(security find-certificate -c "$@" -a -Z "/System/Library/Keychains/SystemRootCertificates.keychain"| grep SHA-1 | awk '{print $NF}')
    if [[ $cert_list != 0 ]] ; then
        for cert in $cert_list
        do
            run sudo security delete-certificate -Z $cert -t "/System/Library/Keychains/SystemRootCertificates.keychain"
        done
    fi
}

delete_certificates "Izenpe.com"
