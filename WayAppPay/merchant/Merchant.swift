//
//  Merchant.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 2/1/20.
//  Copyright © 2020 WayApp. All rights reserved.
//

import Foundation

extension WayAppPay {
    
    struct Merchant: Codable, Identifiable, ContainerProtocol {
        
        static let defaultImageName = "questionmark.square"
        static let defaultName = "missing name"

        var merchantUUID: String
        var name: String?
        var description: String?
        var email: String?
        var address: Address?
        var webside: String?
        var identityDocument: IdentityDocument?
        var logo: String?
        var creationDate: Date?
        var lastUpdateDate: Date?
        var currency: Currency
        
        /*
         address =     {
              addressUUID = "d7690a05-7109-4c01-a15e-fb6516299e3e";
              city = Murcia;
              country = ES;
              line1 = "Avenida General Jose Manuel Platas Varela, n\U00ba388, piso 5\U00ba local 56";
              line2 = "<null>";
              postalCode = 25136;
              stateProvince = Murcia;
          };
          bankAccount =     {
              holder = "Jos\U00e9 Su\U00e1rez Lemus";
              image = "https://s3.eu-central-1.amazonaws.com/paydesarrollo/merchants/628a9e8c-a7b3-497c-bfa5-01cf6410e6e0/banks/9db4a339-f325-4d7f-89eb-b81411ea5dff.png";
              number = 12365478963258741;
              routing = 123654;
          };
          businessCategory = IT;
          commercialContidions =     {
              backup = "0.5";
              standard = "0.5";
              tpvPay = 2;
          };
          creationDate = "2019-10-30T14:22:54Z";
          currency = EUR;
          description = "Soluciones de inform\U00e1ticas";
          email = "sperezleis@hotmail.com";
          identityDocument =     {
              images =         (
                  "https://s3.eu-central-1.amazonaws.com/paydesarrollo/merchants/628a9e8c-a7b3-497c-bfa5-01cf6410e6e0/taxes/508f09d2-b86c-4172-9e47-6918ae2e57f2.jpeg"
              );
              number = 12547896315542;
              type = "TAX_ID";
          };
          lastUpdateDate = "2019-10-30T14:32:39Z";
          legalFormat = "<null>";
          logo = "https://s3.eu-central-1.amazonaws.com/paydesarrollo/merchants/628a9e8c-a7b3-497c-bfa5-01cf6410e6e0/logo/58bc9218-ff62-4837-b2a5-807d3421c5dc.png";
          merchantUUID = "628a9e8c-a7b3-497c-bfa5-01cf6410e6e0";
          name = WayApp;
          representatives =     (
                      {
                  address = "<null>";
                  birthday = "1984-02-09";
                  document =             {
                      images =                 (
                          "https://s3.eu-central-1.amazonaws.com/paydesarrollo/merchants/628a9e8c-a7b3-497c-bfa5-01cf6410e6e0/representatives/287ec87a-1a7c-4a90-8573-18edbc5ad37b/documents/97238723-9c0a-46c0-ba16-9abd0cc0c3af.jpeg",
                          "https://s3.eu-central-1.amazonaws.com/paydesarrollo/merchants/628a9e8c-a7b3-497c-bfa5-01cf6410e6e0/representatives/287ec87a-1a7c-4a90-8573-18edbc5ad37b/documents/1b3d65f3-3387-4eb7-9860-0b7c8ce1a07e.png"
                      );
                      number = 78964123;
                      type = "PERSONAL_ID";
                  };
                  firstName = "Jos\U00e9";
                  lastName = "Su\U00e1rez Lemus";
                  phone = 12543687;
                  representativeUUID = "287ec87a-1a7c-4a90-8573-18edbc5ad37b";
              }
          );
          role = ADMIN;
          status = ENABLED;
          usage =     {
              averageTicket = ONE;
              salesVolume = ONE;
              seasonal = 0;
              type = FIX;
          };
          website = "<null>";

         */
        
        // Protocol Identifiable
        var id: String {
            return merchantUUID
        }

        var containerID: String {
            return merchantUUID
        }

        static func loadMerchantsForAccount(_ accountUUID: String) {
            WayAppPay.API.getMerchants(accountUUID).fetch(type: [WayAppPay.Merchant].self) { response in
                if case .success(let response?) = response {
                    if let merchants = response.result {
                        DispatchQueue.main.async {
                            Session.accountData.merchants.setTo(merchants)
                            Session.merchantUUID = "53259c1c-bf1b-4298-af69-ae84052819dc" // FIXME
                        }
                    } else {
                        WayAppPay.API.reportError(response)
                    }
                } else if case .failure(let error) = response {
                    WayAppUtils.Log.message(error.localizedDescription)
                }
            }
        }
    }
}
