//
//  FacebookModels.swift
//  SocialIntegration
//
//  Created by Neosoft1 on 01/06/22.
//

import Foundation

struct FacebookModel{
    let picture: Picture?
    let name: String?
    let email: String?
    let id: String?
    let gender: String?
    let firstname: String?
    let lastname: String?
    
    enum codingKeys: String, CodingKey{
        case picture = "picture"
        case name = "name"
        case email = "email"
        case id = "id"
        case gender = "gender"
        case firstname = "first_name"
        case lastname = "last_name"
    }
}

extension FacebookModel: Decodable{
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: codingKeys.self)
        picture = try values.decodeIfPresent(Picture.self, forKey: .picture)
        name = try values.decodeIfPresent(String.self, forKey: .name)
        email = try values.decodeIfPresent(String.self, forKey: .email)
        id = try values.decodeIfPresent(String.self, forKey: .id)
        gender = try values.decodeIfPresent(String.self, forKey: .gender)
        firstname = try values.decodeIfPresent(String.self, forKey: .firstname)
        lastname = try values.decodeIfPresent(String.self, forKey: .lastname)
    }
}

struct Picture{
    let data: PictureData?
    
    enum codingKeys: String, CodingKey{
        case data = "data"
    }
}

extension Picture: Decodable{
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: codingKeys.self)
        data = try values.decodeIfPresent(PictureData.self, forKey: .data)
    }
}

struct PictureData{
    let height: Double?
    let width: Double?
    let isSilhouette: Bool?
    let pictureURLString: String?
    var pictureURL: URL?{
        guard pictureURLString != nil else{ return nil }
        return (try? URL(string: pictureURLString!))
    }
    
    enum codingKeys: String, CodingKey{
        case height = "height"
        case width = "width"
        case isSilhouette = "is_silhouette"
        case pictureURLString = "url"
    }
}

extension PictureData: Decodable{
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: codingKeys.self)
        height = try values.decodeIfPresent(Double.self, forKey: .height)
        width = try values.decodeIfPresent(Double.self, forKey: .width)
        isSilhouette = try values.decodeIfPresent(Bool.self, forKey: .isSilhouette)
        pictureURLString = try values.decodeIfPresent(String.self, forKey: .pictureURLString)
    }
}

