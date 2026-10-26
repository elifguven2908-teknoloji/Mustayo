# Mustayo — private couple task journal

A pink romantic web app starter with separate username/password logins, daily questions, completion checkboxes, answers and notes. The owner account can add questions and view the member account's answers. Supabase stores shared data online and Row Level Security policies restrict access to the configured couple.

## Important
This is source code, not a deployed public website yet. You must configure a Supabase project and host the files on a static web host before both phones can use it. Never paste a Supabase `service_role` key into browser code. Only the public anon/publishable key belongs in `app.js`.

## Setup
1. Create a Supabase project at https://supabase.com/ and keep the project URL and public anon/publishable key handy.
2. In **Authentication → Providers → Email**, enable email/password sign-in. For this private two-account alias setup, turn off email confirmations. These usernames are mapped by the app to `username@mustayo.app`; users do not receive email at those aliases, so password recovery by email will not work. Keep the passwords safe.
3. In **Authentication → Users**, create exactly two users with emails `kayo@mustayo.app` and `mustafa@mustayo.app`, using strong unique passwords. Do not add a public sign-up page.
4. Open **SQL Editor**, run all of `schema.sql`. Copy both Auth user UUIDs from Authentication → Users. Uncomment the two profile insert lines at the end of the SQL, replace the UUID placeholders and `SHARED_COUPLE_UUID` with the same newly generated UUID (for example generate one with an online UUID generator), then run those inserts. Kayo is the owner; Mustafa is the member.
5. Open `app.js` and replace `YOUR_SUPABASE_URL` and `YOUR_SUPABASE_ANON_KEY` with the values from Project Settings → API. Do not use a service-role key.
6. Deploy `index.html` and `app.js` together to a static host (for example Netlify or Cloudflare Pages using a static site deployment). Make sure both files are in the same published folder and use the HTTPS URL on both phones.
7. Log in with username `kayo` and the password set for `kayo@mustayo.app`; Mustafa uses username `mustafa` and his own password.

## Included features
- Separate private logins (accounts are manually provisioned; no public registration)
- Four basic questions automatically added for each date when the owner opens that date: food, bathroom, water and headache
- Yes/No answers for the four basic questions, plus optional notes
- Optional extra questions with date selection
- Daily completion checkbox, answer field and note field
- Shared online persistence through Supabase
- Owner view of Mustafa's saved answers and notes
- Row Level Security policies for the couple

## Limitations / security notes
- This starter intentionally omits public registration and password-reset email flow because the alias emails are not real inboxes. If you want password reset, use real emails and adapt login to use them, or add a carefully secured username-login backend.
- The owner can add questions; this starter does not include editing/deleting existing questions, push notifications, or an app-store package.
- Review Supabase policies before production use. Keep the project URL and public anon key only in client code; RLS, not secrecy of the public key, protects user data.
