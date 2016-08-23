//
//  Models.swift
//  Endpoints
//
//  Created by Zak Remer on 8/16/16.
//  Copyright © 2016 Opal. All rights reserved.
//

import Foundation

import Argo
import Curry
import Runes

// MARK: Data Modeling

/// The head matter for a given object.
/// Probably just the id, but a place to add stuff like `created_at`
public struct Head {
    public var id: String
    public var type: String
}

// MARK: Relationships

/// A relationship pointer.
public struct Pointer {
    public var id: String
    public var type: String
}

extension Pointer: Equatable {
    public static func == (lhs: Pointer, rhs: Pointer) -> Bool {
        return lhs.id == rhs.id && lhs.type == rhs.type
    }
}

/// A relationship object.
/// Contains the information about the relationship,
/// resource locations for the related resource,
/// and the related object itself if it's been fetched.
public struct To<Relationship: RelationshipProtocol> {
    /// Links would go here.
    public var data: Related<Relationship>

    public init(pointer: Relationship.PointerType) {
        self.data = .unfetched(pointer)
    }

    public init(model: Relationship.ElementType) {
        self.data = .fetched(model)
    }

    public init(data: Related<Relationship>) {
        self.data = data
    }
}

/// Describes the possible states of a relationship:
/// - unknown: There's not yet any information available about the relationship
/// - unfetched: We know the id(s) of any objects included in the relationship
/// - fetched: We know the actual data for the objects in the relationship
public enum Related<Relationship: RelationshipProtocol> {
    // When the relationship object has no data.
    // As much as I would like to avoid it, it's technically possible in the spec,
    // And I have no reason to believe that we won't end up with it in the API.
    case unknown
    case unfetched(Relationship.PointerType)

    // We don't want an intermediate concept, right?
    // Either we have all the related objects, or we just have all the
    // Pointers?

    case fetched(Relationship.ElementType)

    // Do we want to spend any effort thinking about if the relationship is paged?
    // (Probably not, but presumably you could double check with someone.)
}

//typealias ToOne<Element: Decodable> = To<One<Element>>
//typealias ToMany<Element: Decodable> = To<Many<Element>>
//typealias ToMaybe<Element: Decodable> = To<Maybe<Element>>

public extension Related {
    public var asUnfetched: Relationship.PointerType? {
        guard case let .unfetched(pointer) = self else { return nil }
        return pointer
    }

    public var asFetched: Relationship.ElementType? {
        guard case let .fetched(element) = self else { return nil }
        return element
    }
}

/// Abstract ways to have relationships.
/// These are generally uninitable, and simply exist to define the types that could be found in the relationship value.
public protocol RelationshipProtocol {
    associatedtype PointerType
    associatedtype ElementType

    // So, this feels gross. I would have a strong preference for the Decoding
    // stuff _not_ leak into this, but I don't know how to keep it seperate, since
    // we can't know how to build a To<Relationship<T>> without knowing that T is
    // decodable. We could typealias it, but I don't think that actually buys us
    // anything.

    // What if we have a ToBox of some type, then have ToOne<T> be sugar around
    // To<Box<T>>?
    static func decodePointer(_ json: JSON) -> Decoded<PointerType?>
    static func decodeElement(_ json: JSON) -> Decoded<ElementType>
}

//public enum One<Element: Decodable>: RelationshipProtocol {
//    public typealias PointerType = Pointer
//    public typealias ElementType = Element

//    public static func decodePointer(_ json: JSON) -> Decoded<PointerType> { return Pointer.decode(json) }
//    public static func decodeElement(_ json: JSON) -> Decoded<Element.DecodedType> { return ElementType.decode(json) }
//}

public enum Many<Element>: RelationshipProtocol where Element: Decodable, Element == Element.DecodedType {
    public typealias PointerType = [Pointer]
    public typealias ElementType = [Element]

    public static func decodePointer(_ json: JSON) -> Decoded<[Pointer]?> { return json <||? "data" }
    public static func decodeElement(_ json: JSON) -> Decoded<[Element]> { return Array<Element>.decode(json) }
}

//public enum Maybe<Element: Decodable>: RelationshipProtocol {
//    public typealias PointerType = Optional<Pointer>
//    public typealias ElementType = Optional<Element>
//}

// MARK: - Data Models

struct Author {

    var head: Head

    var name: String
    var birth: Date
    var death: Date?

//    var bookRelationships: ToMany<Book>
//    var photoRelationshipss: ToMany<Photo>
}

struct Book {

    var head: Head

    var title: String
    var published: Date

//    var authorRelationship: ToOne<Author>
//    var seriesRelationship: ToMaybe<Series>

//    var chapterRelationships: ToMany<Chapter>
//    var photoRelationships: ToMany<Photo>
//    var storeRelationships: ToMany<Store>
}

struct Photo {

    var head: Head

    var title: String
    var uri: URL

//    var imageableRelationship: To<One<Imageable>>
}

enum Imageable {
    case author(Author)
    case book(Book)
}

struct Chapter {

    var head: Head

    var title: String
    var ordering: Int

//    var bookRelationship: To<One<Book>>
}

struct Series {

    var head: Head

    var title: String

//    var bookRelationships: To<Many<Book>>
}

public struct Store {
    var head: Head

    var name: String

//    var books: [Boo] { return bookRelationships.data.asFetched ?? [] }
    // or var books: [Book]? ?
    var bookRelationships: To<Many<Boo>>
}

struct Boo {
    var head: Head
    var name: String
}

extension Head: Decodable {
    public static func decode(_ j: Argo.JSON) -> Decoded<Head> {
        return curry(Head.init)
            <^> j <| "id"
            <*> j <| "type"
    }
}

extension Boo: Decodable {
    public static func decode(_ json: JSON) -> Decoded<Boo> {
        return curry(Boo.init)
            <^> json <| []
            <*> json <| ["attributes", "name"]
    }
}

extension Pointer: Decodable {
    public static func decode(_ json: JSON) -> Decoded<Pointer> {
        return curry(Pointer.init)
            <^> json <| "id"
            <*> json <| "type"
    }
}

extension To: Decodable {
    public static func decode(_ json: JSON) -> Decoded<To<Relationship>> {
        return Relationship.decodePointer(json).map { pointer in
            pointer.map(self.init(pointer:)) ?? self.init(data: .unknown)
        }
    }
}

extension Store: Decodable {

    public static func decode(_ json: JSON) -> Decoded<Store> {
        return curry(Store.init)
            <^> json <| []
            <*> json <| ["attributes", "name"]
            <*> json <| ["relationships", "books"]
    }
}











