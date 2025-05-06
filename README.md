# Custom Fields API

A Rails 7 API-only application enabling each Tenant to define arbitrary custom fields for its Users, with robust type and options validation.

## Key Features

* **Dynamic Custom Fields**: Tenants can configure any number of fields of types `text`, `number`, `single_select`, or `multi_select`.
* **JSONB Storage**:

  * `tenants.custom_fields_settings` stores an array of field definitions.
  * `users.custom_field_values` stores a hash of user-provided values keyed by field `key`.
* **Service Objects**:

  * `CustomFields::SettingsValidator` validates and sanitizes tenant field definitions.
  * `CustomFields::ValuesSanitizer` validates user inputs against definitions (type checks, select options).
* **GIN Indexes**: Concurrent GIN indexes on both JSONB columns for performant querying.
* **RSpec Test Coverage**: Request specs for controllers + unit specs for service objects.

## Setup & Installation

### Requirements

* **Ruby** `3.3.5`
* **Rails** `7.2.2.1` (API-only)
* **PostgreSQL**

### Installation Steps

1. Clone the repository:

   ```bash
   git clone git@github.com:Wayzyk/cfd.git
   cd cfd
   ```
2. Install dependencies:

   ```bash
   bundle install
   ```
3. Setup the database:

   ```bash
   rails db:create
   rails db:migrate
   rails db:seed
   ```
4. Run the test suite:

   ```bash
   bundle exec rspec
   ```
5. Start the server:

   ```bash
   rails server
   ```

   The API listens on `http://localhost:3000` by default.

## Demo Data

Seeds create a **Demo Tenant** with these fields:

* **phone** (`number`)
* **status** (`single_select`, options: `active`, `inactive`)
* **tags** (`multi_select`, options: `ruby`, `rails`, `api`)

And two users (`alice@example.com`, `bob@example.com`) with sample values.

## API Endpoints

### Update Tenant Settings

```http
PATCH /tenants/:id
Content-Type: application/json
```

**Request Body**:

```json
{
  "tenant": {
    "custom_fields_settings": [
      { "key":"phone","label":"Phone","type":"number","options":[] },
      { "key":"status","label":"Status","type":"single_select","options":["active","inactive"] }
    ]
  }
}
```

**Responses**:

* `200 OK`: returns updated Tenant JSON including `custom_fields_settings` with symbolized keys.
* `422 Unprocessable Entity`: invalid structure or definitions.

### Update User Values

```http
PATCH /users/:id
Content-Type: application/json
```

**Request Body**:

```json
{
  "user": {
    "custom_field_values": { "phone":"+48123456789","status":"active","tags":["ruby"] }
  }
}
```

**Responses**:

* `200 OK`: returns updated User JSON with `custom_field_values`.
* `422 Unprocessable Entity`: invalid values (e.g. non-numeric for `number`, outside options for selects).
* `400 Bad Request`: missing `user` root key.

## Architecture & Code Overview

* **Models**:

  * `Tenant` has a JSONB column and custom validation in `validate_custom_fields_settings_format`.
  * `User` has a JSONB column and helper methods `custom_value`/`set_custom_value`.
* **Controllers** delegate sanitization & validation to service objects.
* **Service Objects** live under `app/services/custom_fields/`:

  * `SettingsValidator` ensures definitions are correct.
  * `ValuesSanitizer` enforces value types and select options.
* **Indexes**: GIN indexes created `concurrently` for both JSONB columns.

## Testing

* **Request Specs**: `spec/requests/tenants_spec.rb`, `spec/requests/users_spec.rb`.
* **Service Specs**: `spec/services/custom_fields/settings_validator_spec.rb`, `spec/services/custom_fields/values_sanitizer_spec.rb`.
* **Factories**: FactoryBot + Faker for tenants and users.

Run all tests with:

```bash
bundle exec rspec
```

## Assumptions

* No authentication or authorization layer.
* Custom fields scoped to Users (future: other entities).
* Basic structure and type validation; additional constraints (length, format) can be layered.

## Future Improvements

* **Polymorphic Custom Fields**: Imagine adding these same dynamic fields to any model in your app—be it a Project, an Order, or a Product. By introducing a polymorphic association layer, you could manage custom fields and values for multiple resources with a single, unified API.
* **Extended Validations**: Beyond basic type checking, you could enforce maximum length on text inputs, numeric ranges (e.g., 0–100), or even complex regex patterns for formats like emails and phone numbers. This would give tenants more control over their data quality without touching the core application code.
* **OpenAPI/Swagger**: integrate `rswag` for interactive API documentation.
* **Bulk Imports**: background jobs for CSV/JSON imports of user values.

