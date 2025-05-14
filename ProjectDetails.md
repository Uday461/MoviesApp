# Project Details

## About Architecture:

- This project employs the MVVM architecture. The ViewModel acts as the bridge between the View, which houses UI elements, and the Model, which encapsulates the application's core business logic. The ViewModel is responsible for managing and persisting UI state.

## Features

- Home Screen: Displays lists of trending and now-playing movies.

- Movie Details: Provides a detailed view of a selected movie.

- Bookmarking: Allows users to bookmark movies.

- Offline Functionality: Stores fetched movie data in CoreData to enable offline access.

- Search: Implements movie search with a 1-second debounce to provide results as the user types.

- Image Caching: Utilizes NSCache with an expiration for efficient image loading.

- DeepLink: Implements movie sharing by creating deep links that route users directly to the selected movie.

- Pagination: Supports paginated loading of movie lists.
