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

(provide 'biblio-openlibrary)
;;; biblio-openlibrary.el ends here
