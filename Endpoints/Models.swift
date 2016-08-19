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
public struct To<Relationship: RelationshipType> {
    /// Links would go here.
    public var data: Related<Relationship>

    public init(_ pointer: Relationship.PointerType) {
        self.data = .unfetched(pointer)
    }

    public init(_ model: Relationship.ElementType) {
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
public enum Related<Relationship: RelationshipType> {
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

typealias ToOne<Element> = To<One<Element>>
typealias ToMany<Element> = To<Many<Element>>
typealias ToMaybe<Element> = To<Maybe<Element>>

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
public protocol RelationshipType {
    associatedtype PointerType
    associatedtype ElementType
}

public enum One<Element>: RelationshipType {
    public typealias PointerType = Pointer
    public typealias ElementType = Element
}

public enum Many<Element>: RelationshipType {
    public typealias PointerType = Array<Pointer>
    public typealias ElementType = Array<Element>
}

public enum Maybe<Element>: RelationshipType {
    public typealias PointerType = Optional<Pointer>
    public typealias ElementType = Optional<Element>
}

// MARK: - FromJSONification
typealias JSON = [String : AnyObject]
protocol FromJSONable { init?(json: JSON) }

func attribute<T>(from: JSON, at: String) -> T? {
    let attributes = from["attributes"] as? JSON
    return attributes?[at] as? T
}

// MARK: - Data Models

struct Author {

    var head: Head

    var name: String
    var birth: Date
    var death: Date?

    var bookRelationships: ToMany<Book>
    var photoRelationshipss: ToMany<Photo>
}

struct Book {

    var head: Head

    var title: String
    var published: Date

    var authorRelationship: ToOne<Author>
    var seriesRelationship: ToMaybe<Series>

    var chapterRelationships: ToMany<Chapter>
    var photoRelationships: ToMany<Photo>
    var storeRelationships: ToMany<Store>
}

struct Photo {

    var head: Head

    var title: String
    var uri: URL

    var imageableRelationship: To<One<Imageable>>
}

enum Imageable {
    case author(Author)
    case book(Book)
}

struct Chapter {

    var head: Head

    var title: String
    var ordering: Int

    var bookRelationship: To<One<Book>>
}

struct Series {

    var head: Head

    var title: String

    var bookRelationships: To<Many<Book>>
}

struct Store {
    var head: Head

    var name: String

    var books: [Book] { return bookRelationships.data.asFetched ?? [] }
    // or var books: [Book]? ?
    var bookRelationships: To<Many<Book>>
}

extension Store: FromJSONable {
    init?(json: JSON) {
        guard
            let id: String = json["id"] as? String,
            let name: String = attribute(from: json, at: "name")
        else { return nil }

        self.head = Head(id: id)
        self.name = name
        self.bookRelationships = To(data: .unknown)
    }
}











