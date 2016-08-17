//
//  Models.swift
//  Endpoints
//
//  Created by Zak Remer on 8/16/16.
//  Copyright © 2016 Opal. All rights reserved.
//

import Foundation


// MARK: Data Modeling

/// The head matter for a given object.
/// Probably just the id, but a place to add stuff like `created_at`
struct Head { var id: String }

// MARK: Relationships

/// A relationship pointer.
struct Pointer { var id: String; var type: String }

/// A relationship object.
/// Contains the information about the relationship,
/// resource locations for the related resource,
/// and the related object itself if it's been fetched.
struct To<Relationship: RelationshipType> {
    /// Links would go here.
    var friend: Related<Relationship>
}

/// Abstract ways to have relationships.
/// These are generally uninitable, and simply exist to define the types that could be found in the relationship value.
protocol RelationshipType { associatedtype PointerType; associatedtype ElementType }
enum One<Element>: RelationshipType { typealias PointerType = Pointer; typealias ElementType = Element }
enum Many<Element>: RelationshipType { typealias PointerType = Array<Pointer>; typealias ElementType = Array<Element> }
enum Maybe<Element>: RelationshipType { typealias PointerType = Optional<Pointer>; typealias ElementType = Optional<Pointer> }

/// Describes the possible states of a relationship:
/// - unknown: There's not yet any information available about the relationship
/// - unfetched: We know the id(s) of any objects included in the relationship
/// - fetched: We know the actual data for the objects in the relationship
enum Related<Relationship: RelationshipType> {
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

// MARK: - Data Models

struct Author {

    var head: Head

    var name: String
    var birth: Date
    var death: Date?

    var books: To<Many<Book>>
    var photos: To<Many<Photo>>
}

struct Book {

    var head: Head

    var title: String
    var published: Date

    var author: To<One<Author>>
    var series: To<Maybe<Series>>

    var chapters: To<Many<Chapter>>
    var photos: To<Many<Photo>>
    var stores: To<Many<Store>>
}

struct Photo {

    var head: Head

    var title: String
    var uri: URL

    var imageable: To<One<Imageable>>
}

enum Imageable {
    case author(Author)
    case book(Book)
}

struct Chapter {

    var head: Head

    var title: String
    var ordering: Int

    var book: To<One<Book>>
}

struct Series {

    var head: Head

    var title: String
    var books: To<Many<Book>>
}

struct Store {
    var head: Head

    var name: String

    var books: To<Many<Book>>
}













