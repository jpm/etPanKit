//
//  LEPCertificateUtils.m
//  etPanKit
//
//  Created by DINH Viêt Hoà on 11/25/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LEPCertificateUtils.h"
#import <Security/Security.h>

BOOL lepCheckCertificate(mailstream * stream, NSString * host)
{
    ssize_t size;
    unsigned char * cert_DER;
    SecCertificateRef cert;
    OSStatus r;
    SecTrustResultType trustResult;
    SecTrustRef trust;
    SecPolicyRef policy;
    SecPolicySearchRef policySearch;
    CSSM_OID policyID;
    BOOL valid;
    
    valid = NO;
    
    size = mailstream_ssl_get_certificate(stream, &cert_DER);
    if (size < 0) {
        goto err;
    }
    
    CSSM_DATA certData;
    certData.Data = (uint8 *) cert_DER;
    certData.Length = size;
    r = SecCertificateCreateFromData(&certData,
                                     CSSM_CERT_X_509v3,
                                     CSSM_CERT_ENCODING_DER, &cert);
    if (r < 0) {
        goto free_der;
    }
    
    policyID = CSSMOID_APPLE_TP_SSL;
    r = SecPolicySearchCreate(CSSM_CERT_X_509v3, &policyID, NULL,
                              &policySearch);
    if (r < 0) {
        goto free_cert;
    }
    
    r = SecPolicySearchCopyNext(policySearch, &policy);
    if (r < 0) {
        goto free_policy_search;
    }
    
    const char * cHostname = [host UTF8String];
    CSSM_APPLE_TP_SSL_OPTIONS ssloptions = {
		.Version = CSSM_APPLE_TP_SSL_OPTS_VERSION,
		.ServerNameLen = strlen(cHostname),
		.ServerName = cHostname,
		.Flags = 0
	};
	CSSM_DATA customCssmData = {
		.Length = sizeof(ssloptions),
		.Data = (uint8*)&ssloptions
	};
	r = SecPolicySetValue(policy, &customCssmData);
	if(r != noErr) {
        goto free_policy;
	}
    
    r = SecTrustCreateWithCertificates((CFTypeRef) [NSArray arrayWithObject:(id) cert], (CFTypeRef) policy, &trust);
    if (r < 0) {
        goto free_policy;
    }
    
    r = SecTrustEvaluate(trust, &trustResult);
    if (r < 0) {
        goto free_trust;
    }
    
    switch(trustResult) {
		case kSecTrustResultProceed:
            // Accepted by user keychain setting explicitly
		case kSecTrustResultUnspecified:
            // See http://developer.apple.com/qa/qa2007/qa1360.html
		    // Unspecified means that the user never expressed any persistent opinion about
		    // this certificate (or any of its signers). Either this is the first time this certificate
		    // has been encountered (in these circumstances), or the user has previously dealt with it
		    // on a one-off basis without recording a persistent decision. In practice, this is what
		    // most (cryptographically successful) evaluations return.
		    // If the certificate is invalid kSecTrustResultUnspecified can never be returned.
            valid = YES;
            break;
    }
    
free_trust:
    CFRelease(trust);
free_policy:
    CFRelease(policy);
free_policy_search:
    CFRelease(policySearch);
free_cert:
    CFRelease(cert);
free_der:
    free(cert_DER);
err:
    return valid;
}
