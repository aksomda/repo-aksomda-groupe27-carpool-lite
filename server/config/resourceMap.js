// Associe chaque collection Firestore synchronisée à sa table MySQL et à la
// façon de transformer le document Firestore (camelCase) en ligne MySQL
// (snake_case). Ajouter une nouvelle collection à synchroniser ne nécessite
// que d'ajouter une entrée ici + la table correspondante dans sql/schema.sql.
//
// Hiérarchie académique : universities -> campus -> ufrs -> formations -> academic_levels

const resourceMap = {
  universities: {
    table: 'universities',
    toRow: (id, data) => ({
      id,
      name: data.name || '',
      city: data.city || '',
      address: data.address || '',
      latitude: data.latitude != null ? String(data.latitude) : '',
      longitude: data.longitude != null ? String(data.longitude) : '',
      is_deleted: data.isDeleted ? 1 : 0,
    }),
  },
  campus: {
    table: 'campus',
    toRow: (id, data) => ({
      id,
      name: data.name || '',
      code: data.code || '',
      university_id: data.universityId || '',
      university_name: data.universityName || '',
      is_deleted: data.isDeleted ? 1 : 0,
    }),
  },
  ufrs: {
    table: 'ufrs',
    toRow: (id, data) => ({
      id,
      name: data.name || '',
      code: data.code || '',
      campus_id: data.campusId || '',
      campus_name: data.campusName || '',
      is_deleted: data.isDeleted ? 1 : 0,
    }),
  },
  formations: {
    table: 'formations',
    toRow: (id, data) => ({
      id,
      name: data.name || '',
      code: data.code || '',
      diploma: data.diploma || '',
      ufr_id: data.ufrId || '',
      ufr_name: data.ufrName || '',
      is_deleted: data.isDeleted ? 1 : 0,
    }),
  },
  academic_levels: {
    table: 'academic_levels',
    toRow: (id, data) => ({
      id,
      name: data.name || '',
      academic_year: data.academicYear || '',
      formation_id: data.formationId || '',
      formation_name: data.formationName || '',
      is_deleted: data.isDeleted ? 1 : 0,
    }),
  },
};

module.exports = resourceMap;
