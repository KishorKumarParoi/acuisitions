export const formatValidationErrors = (errors) => {
  if (!errors || errors.issues === 0) {
    return 'Validation Failed';
  }

  if (Array.isArray(errors.issues)) {
    return errors.issues
      .map((issue) => {
        return `${issue.path.join('.')} : ${issue.message}`;
      })
      .join('; ');
  }

  return JSON.stringify(errors);
};
