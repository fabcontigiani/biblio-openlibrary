;;; biblio-openlibrary.el --- Lookup and import bibliographic entries from OpenLibrary  -*- lexical-binding: t; -*-

;; Copyright (C) 2024  Fabrizio Contigiani

;; Author: Fabrizio Contigiani <fabcontigiani@gmail.com>
;; URL: https://github.com/fabcontigiani/biblio-openlibrary
;; Keywords: bibtex, biblio, openlibrary
;; Version: 0.0.1

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:
;;
;; Lookup and download bibliographic records from OpenLibrary using
;;`openlibrary-lookup'.
;;
;; This file implements a backend for the `biblio' package (which see for more
;; documentation).

;;; Code:

(require 'biblio-core)

(defun biblio-openlibrary--build-bibtex (metadata)
  "Create an unformated BibTeX record for METADATA"
  (let-alist metadata
    (format "@%s{NO_KEY,
author = {%s},
title = {%s},
publisher = {%s}
year = {%s},
isbn = {%s},
url = {%s}}"
            .type (biblio-join-1 " and " .authors) .title
            (biblio-join-1 " " .publisher) .year (car .references) .url)))

(defun biblio-openlibrary--format-bibtex (metadata)
  "Format a BibTeX record for METADATA autogenerating a key."
  (biblio-format-bibtex (biblio-openlibrary--build-bibtex metadata) t))

(defun biblio-openlibrary--forward-bibtex (metadata forward-to)
  "Forward BibTeX for OpenLibrary entry METADATA to FORWARD-TO."
  (funcall forward-to (biblio-openlibrary--format-bibtex metadata)))

(defun biblio-openlibrary--extract-interesting-fields (item)
  "Prepare a OpenLibrary search result ITEM for display."
  (let-alist (cdr item)
    (list (cons 'title (biblio-join ": " .data.title .data.subtitle))
          (cons 'authors (mapcar #'cdadr .data.authors))
          (cons 'type "book")
          (cons 'category (take 3 (mapcar #'cdar .data.subjects))) ;; TODO: make customizable
          (cons 'publisher (mapcar #'cdar .data.publishers))
          (cons 'references (seq-mapcat #'identity
                                        (mapcar #'cdr .data.identifiers)))
          (cons 'url .data.url)
          (cons 'year (format-time-string
                       "%Y"
                       (encode-time
                        (decoded-time-set-defaults
                         (parse-time-string .data.publish_date))))))))

(defun biblio-openlibrary--parse-search-results ()
  "Extract search results from OpenLibrary response."
  (biblio-decode-url-buffer 'utf-8)
  (let-alist (json-read)
    (unless (length> .records 0)
      (display-warning 'biblio-openlibrary "OpenLibrary query failed"))
    (seq-map #'biblio-openlibrary--extract-interesting-fields .records)))

(defun biblio-openlibrary--url (query)
  "Create a OpenLibrary url to look up QUERY."
  (format "http://openlibrary.org/api/volumes/brief/isbn/%s.json"
          (url-encode-url query)))

;;;###autoload
(defun biblio-openlibrary-backend (command &optional arg &rest more)
  "A openlibrary backend for biblio.el.
COMMAND, ARG, MORE: See `biblio-backends'."
  (pcase command
    (`name "OpenLibrary")
    (`prompt "OpenLibrary query: ")
    (`url (biblio-openlibrary--url arg))
    (`parse-buffer (biblio-openlibrary--parse-search-results))
    (`forward-bibtex (biblio-openlibrary--forward-bibtex arg (car more)))
    (`register (add-to-list 'biblio-backends #'biblio-openlibrary-backend))))

;;;###autoload
(add-hook 'biblio-init-hook #'biblio-openlibrary-backend)

;;;###autoload
(defun biblio-openlibrary-lookup (&optional query)
  "Start an OpenLibrary search for QUERY, prompting if needed."
  (interactive)
  (biblio-lookup #'biblio-openlibrary-backend query))

;;;###autoload
(defalias 'openlibrary-lookup 'biblio-openlibrary-lookup)

(provide 'biblio-openlibrary)
;;; biblio-openlibrary.el ends here
